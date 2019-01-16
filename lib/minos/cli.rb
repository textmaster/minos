module Minos
  class CLI < Thor

    class_option :manifest, default: "./docker-artifacts.yaml", desc: "Manifest config file to build docker artifacts"
    class_option :revision, default: ENV['REVISION'], desc: "Git revision hash"
    class_option :only, type: :array, default: [], desc: "Builds only specified artifacts"
    class_option :except, type: :array, default: [], desc: "Builds all but specified artifacts"

    desc "build", ""
    method_option :branch, default: ENV['BRANCH_NAME'], desc: "Git branch name"
    def build
      invoke 'minos:docker:build', []
    end

    desc "push", ""
    method_option :branch, default: ENV['BRANCH_NAME'], desc: "Git branch name"
    def push
      invoke 'minos:docker:push', []
    end

    desc "deploy", ""
    def deploy
      invoke 'minos:k8s:deploy', []
    end
  end
end
