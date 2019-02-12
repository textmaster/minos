require 'active_support/core_ext/string/inflections'

module Minos
  class Artifact
    include Dry::Monads::Result::Mixin

    attr_reader :artifact, :options

    def initialize(artifact, options: {})
      @artifact = artifact
      @options = options
    end

    def name
      artifact['name']
    end

    def pull
      caches.map do |cache|
        docker_pull(cache)
      end
    end

    def build
      docker_build
    end

    def push
      docker_push
    end

    private

    def docker_pull(cache)
      if run "docker inspect #{cache} -f '{{json .ID}}' > /dev/null 2>&1 || docker pull #{cache} 2> /dev/null"
        Success(cache)
      else
        Failure(cache)
      end
    end

    def docker_build
      if run "docker build #{to_args(docker)} ."
        Success(name)
      else
        Failure(name)
      end
    end

    def docker_push
      tags.map do |tag|
        if run "docker tag #{image}:#{target} #{image}:#{tag} && docker push #{image}:#{tag}"
          Success("#{image}:#{tag}")
        else
          Failure("#{image}:#{tag}")
        end
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
