module Minos
  class Docker < Thor
    class_option :manifest, default: "./docker-artifacts.yaml", desc: "Manifest config file to build docker artifacts"
    class_option :branch, default: ENV['BRANCH_NAME'], desc: "Git branch name"
    class_option :revision, default: ENV['REVISION'], desc: "Git revision hash"
    class_option :only, type: :array, default: [], desc: "Builds only specified artifacts"
    class_option :except, type: :array, default: [], desc: "Builds all but specified artifacts"

    desc "build", "Build docker artifacts"
    def build
      artifacts.each do |a|
        artifact = Artifact.new(a, options: options)
        artifact.pull
        artifact.build
      end
    end

    desc "push", "Push docker artifacts"
    def push
      artifacts.each do |a|
        artifact = Artifact.new(a, options: options)
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
