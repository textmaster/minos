require 'yaml'
require 'thor'

require 'minos/artifact'
require 'minos/docker'
require 'minos/k8s'
require 'minos/cli'
require 'minos/version'

module Minos
  class Error < StandardError; end
end
