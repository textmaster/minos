require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

module Minos
  class Artifact
    include Wisper::Publisher

    attr_reader :artifact, :options

    def initialize(artifact, options: {})
      @artifact = artifact
      @options = options
    end

    def name
      artifact['name']
    end

    def pull
      caches.each do |name|
        docker_pull(name)
      end
    end

    def build
      docker_build
    end

    def push
      docker_push
    end

    private

    def docker_pull(name)
      broadcast(:pulling_cache_artifact, name)
      run "docker inspect #{name} -f '{{json .ID}}' > /dev/null 2>&1 || docker pull #{name} 2> /dev/null"
    end

    def docker_build
      broadcast(:building_artifact, name)
      status = run "docker build #{to_args(docker)} ."
      if status.success?
        broadcast(:artifact_built, name)
      else
        broadcast(:artifact_build_failed, name)
      end
    end

    def docker_push
      tags.each do |tag|
        status = run "docker tag #{image}:#{target} #{image}:#{tag}"
        if status.success?
          broadcast(:artifact_tagged, "#{image}:#{target}", "#{image}:#{tag}")
        else
          broadcast(:artifact_tag_failed, "#{image}:#{target}", "#{image}:#{tag}")
        end

        status = run "docker push #{image}:#{tag}"
        if status.success?
          broadcast(:artifact_pushed, "#{image}:#{tag}")
        else
          broadcast(:artifact_push_failed, "#{image}:#{tag}")
        end
      end
    end

    def run(cmd)
      stdout, stderr, status = Open3.capture3(envs, cmd)
      puts stdout unless stdout.empty?
      puts stderr unless stderr.empty?

      return status
    end

    def envs
      {
        'IMAGE'  => image,
        'TARGET' => target,
      }
    end

    def docker
      artifact['docker']
    end

    def caches
      docker['cacheFrom']
    end

    def image
      artifact['image']
    end

    def target
      docker['target']
    end

    def tags
      artifact['tags'].to_a
    end

    def to_args(args)
      args.map do |key, value|
        case value
        when Array
          value.map do |v|
            "--#{key.underscore.gsub('_', '-')} #{v}"
          end
        when Hash
          value.map do |k, v|
            "--#{key.underscore.gsub('_', '-')} #{k}=#{v}"
          end
        else
          "--#{key.underscore.gsub('_', '-')} #{value}"
        end
      end.flatten.join(' ')
    end
  end
end
