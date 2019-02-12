module Minos
  class Docker < Thor
    include Thor::Shell

    class_option :manifest, default: "./minos.yaml", desc: "Manifest config file describing docker artifacts"
    class_option :only, type: :array, default: [], desc: "Process only given artifacts"
    class_option :except, type: :array, default: [], desc: "Process all but given artifacts"

    desc "build", "Build docker artifacts specified in the manifest"
    def build
      artifacts.each do |a|
        artifact = Artifact.new(a, options: options)

        # Pull
        artifact.pull.each do |result|
          Dry::Matcher::ResultMatcher.(result) do |m|
            m.success do |name|
              say_status artifact.name, "Using #{name}"
            end
            m.failure do |name|
              # noop
              # failure here means we don't have docker image locally
            end
          end
        end

        # Build
        Dry::Matcher::ResultMatcher.(artifact.build) do |m|
          m.success do |name|
            say_status artifact.name, "Successfully built #{name}"
          end
          m.failure do |name|
            say_status artifact.name, "Failed building #{name}", :red
            exit 1
          end
        end
      end
    end

    desc "push", "Publish docker artifacts specified in the manifest"
    def push
      artifacts.each do |a|
        artifact = Artifact.new(a, options: options)
        artifact.push.each do |result|
          Dry::Matcher::ResultMatcher.(result) do |m|
            m.success do |name|
              say_status artifact.name, "Successfully pushed #{name}"
            end
            m.failure do |name|
              say_status artifact.name, "Failed pushing #{name}", :red
              exit 1
            end
          end
        end
      end
    end

    private

    def artifacts
      artifacts = parse['build']['artifacts'].to_a
      artifacts.reject! { |a| options[:except].include?(a['name']) } if options[:except].count > 0
      artifacts.select! { |a| options[:only].include?(a['name']) } if options[:only].count > 0
      artifacts
    end

    def parse
      @parse ||= YAML.load(read)
    end

    def read
      File.read(options[:manifest])
    end
  end
end
