module Minos
  class CLI < Thor
    include Thor::Shell

    desc "build", "Build docker artifacts specified in the manifest"
    option :manifest, default: "./minos.yaml", desc: "Manifest config file describing docker artifacts"
    option :only, type: :array, default: [], desc: "Process only given artifacts"
    option :except, type: :array, default: [], desc: "Process all but given artifacts"
    def build
      results = artifacts.map do |a|
        artifact = Artifact.new(a, options: options)
        artifact.build
      end

      exit 1 if results.any?(&:failure?)

      results
    end

    desc "push", "Publish docker artifacts specified in the manifest"
    option :manifest, default: "./minos.yaml", desc: "Manifest config file describing docker artifacts"
    option :only, type: :array, default: [], desc: "Process only given artifacts"
    option :except, type: :array, default: [], desc: "Process all but given artifacts"
    def push
      results = artifacts.map do |a|
        artifact = Artifact.new(a, options: options)
        artifact.push
      end

      exit 1 if results.any?(&:failure?)

      results
    end

    desc "version", "Display Minos version"
    def version
      puts Minos::VERSION
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
