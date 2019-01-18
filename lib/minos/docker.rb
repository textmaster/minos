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
        say_status "minos", "Pulling \"#{artifact.name}\" artifact cached layers"
        artifact.pull
        say_status "minos", "Building \"#{artifact.name}\" artifact"
        artifact.build
      end
    end

    desc "push", "Publish docker artifacts specified in the manifest"
    def push
      artifacts.each do |a|
        artifact = Artifact.new(a, options: options)
        say_status "minos", "Publishing \"#{artifact.name}\" artifact"
        artifact.push
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
