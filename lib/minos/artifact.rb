# frozen_string_literal: true

require 'open3'
require 'minos/utils'
require 'active_support/core_ext/string/inflections'

module Minos
  class Artifact
    include Dry::Monads::Result::Mixin
    include Dry::Monads::Task::Mixin
    include Dry::Monads::List::Mixin
    include Dry::Monads::Try::Mixin
    include Dry::Monads::Do.for(:build, :push)
    include Thor::Shell

    attr_reader :artifact, :options

    def initialize(artifact, options: {})
      @artifact = artifact
      @options = options
    end

    def name
      artifact['name']
    end

    def build
      docker_build.to_result
    end

    def push
      yield List::Task[
        *tags.map.each_with_index { |tag, i| docker_push(i, tag) }
      ]
      .traverse
      .to_result
    end

    private

    def docker_build
      Task[:io, &-> {
        color = :green
        print "Building #{target}...", color: color
        if run "docker build --rm --build-arg BUILDKIT_INLINE_CACHE=1 #{Minos::Utils.to_args(docker)} .", color: color
          print "Successfully built #{target}", color: color
          return Success()
        else
          print "Failed building #{target}", color: :red
          return Failure($?)
        end
      }]
    end

    def docker_push(i, tag)
      Task[:io, &-> {
        color = select_color(i)
        print "Pushing #{image}:#{tag}...", color: color
        if run "docker tag #{image}:#{target} #{image}:#{tag} && docker push #{image}:#{tag}", color: color
          print "Successfully pushed #{image}:#{tag}", color: color
          return Success()
        else
          print "Failed pushing #{image}:#{tag}", color: :red
          return Failure($?)
        end
      }]
    end

    def run(cmd, color: colors.first)
      Open3.popen3("#{Minos::Utils.to_envs(env)} ; #{cmd}") do |stdin, stdout, stderr, wait_thr|
        t_out = Thread.new do
          while line = stdout.gets do
            print(line, color: color)
          end
        end

        t_err = Thread.new do
          while line = stderr.gets do
            print(line, color: :red)
          end
        end

        wait_thr.join
        t_err.join
        t_out.join

        stdin.close
        stdout.close
        stderr.close

        wait_thr.value.success?
      end
    end

    def print(msg, color: colors.first)
      say_status(name, msg, color)
    end

    def select_color(i)
      colors[i % colors.count]
    end

    def colors
      %i(blue cyan yellow magenta)
    end

    def env
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
  end
end
