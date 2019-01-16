module Minos
  class CLI < Thor
    class_option :manifest, default: "./docker-artifacts.yaml", desc: "Manifest config file describing docker artifacts"
    class_option :only, type: :array, default: [], desc: "Process only given artifacts"
    class_option :except, type: :array, default: [], desc: "Process all but given artifacts"

    desc "build", "Build docker artifacts specified in the manifest"
    def build
      invoke 'minos:docker:build', []
    end

    desc "push", "Publish docker artifacts specified in the manifest"
    def push
      invoke 'minos:docker:push', []
    end

    desc "deploy", "Deploy docker artifacts specified in the manifest"
    def deploy
      invoke 'minos:k8s:deploy', []
    end
  end
end
