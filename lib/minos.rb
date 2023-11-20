# frozen_string_literal: true

require 'yaml'
require 'thor'
require 'dry/monads'

require 'minos/artifact'
require 'minos/cli'
require 'minos/version'

module Minos
  class Error < StandardError; end
end
