require 'padrino-core'
require 'padrino-gen'
require 'padrino-helpers'  
require 'mongo_mapper'
require 'mongomapper_ext'

FileSet.glob_require('garry/*.rb', __FILE__)
FileSet.glob_require('garry/{helpers,models,jobs}/*.rb', __FILE__)       

unless defined?(Airbrake) and Padrino.env == :production
  module Airbrake
    def self.notify(thing)
      # do nothing.
    end
  end            
end

module Garry
  class << self     
    def registered(app)
      app.enable :sessions
      app.helpers Garry::Helpers::CartHelpers   
    end
    alias :included :registered     
  end
end      