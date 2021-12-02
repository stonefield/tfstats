require "tfstats/version"
require "tfstats/collector"

module Tfstats
  class Error < StandardError; end
  # Your code goes here...
  %i(dryrun verbose).each do |key|
    self.class.define_method(key) do
      instance_variable_get(:"@#{key}")
    end
    self.class.define_method(:"#{key}=") do |value|
      instance_variable_set(:"@#{key}", value)
    end
  end
end
