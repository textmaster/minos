require 'active_support/core_ext/string/inflections'

module Minos
  class Artifact
    attr_reader :artifact, :options

    def initialize(artifact, options: {})
      @artifact = artifact
      @options = options
    end

    def pull
      caches.each do |cache|
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
      run "docker inspect #{cache} -f '{{json .ID}}' > /dev/null 2>&1 || docker pull #{cache} 2> /dev/null"
    end

    def docker_build
      run "docker build #{to_args(docker)} ."
    end

    def docker_push
      tags.each do |tag|
        run "docker tag #{image}:#{target} #{image}:#{tag}"
        run "docker push #{image}:#{tag}"
      end
    end

    def run(cmd)
      system("#{envs_as_cmd} && #{cmd}")
    end

    def envs
      {
        'IMAGE'       => image,
        'TARGET'      => target,
        'BRANCH_NAME' => options[:branch].to_s.strip,
        'REVISION'    => options[:revision].to_s.strip,
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
