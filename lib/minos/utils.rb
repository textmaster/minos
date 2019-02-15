module Minos
  class Utils
    # Flatten args as an array, hash or string into CLI args.
    def self.to_args(args)
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

    # Flatten env as hash into shell's environment variables.
    def self.to_envs(env)
      env.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
    end
  end
end
