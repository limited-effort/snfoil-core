# frozen_string_literal: true

# Copyright 2021 Matthew Howes

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/inflector'
require 'logger'



module SnFoil
  class Error < StandardError; end

  mattr_accessor :orm, default: 'active_record'
  mattr_writer :logger

  class << self
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    def adapter
      return @adapter if @adapter

      @adapter ||= if orm.instance_of?(String) || orm.instance_of?(Symbol)
                     require_relative "snfoil/adapters/orms/#{ActiveSupport::Inflector.underscore(orm)}"
                     constant = "SnFoil::Adapters::ORMs::#{ActiveSupport::Inflector.camelize(orm)}"
                     if Object.const_defined?(constant)
                       ActiveSupport::Inflector.constantize(constant)
                     else
                      ActiveSupport::Inflector.constantize(orm)
                     end
                   else
                     orm
                   end
    end

    def configure
      yield self
    end
  end
end
