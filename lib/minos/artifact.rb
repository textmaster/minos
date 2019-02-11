require 'active_support/core_ext/string/inflections'

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
      run "docker build #{to_args(docker)} ."
      broadcast(:artifact_built, name)
    end

    def docker_push
      tags.each do |tag|
        broadcast(:tagging_artifact, "#{image}:#{target}", "#{image}:#{tag}")
        run "docker tag #{image}:#{target} #{image}:#{tag}"
        broadcast(:pushing_artifact, "#{image}:#{tag}")
        run "docker push #{image}:#{tag}"
      end
    end

    def run(cmd)
      system("#{envs_as_cmd} && #{cmd}")
    end

    def envs
      {
        'IMAGE'  => image,
        'TARGET' => target,
      }
    end

    def envs_as_cmd
      envs.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
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
