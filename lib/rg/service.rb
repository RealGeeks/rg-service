require "active_support"
require "virtus"

require_relative "service/version"
require_relative "service/kill_switch"
require_relative "service/result"
require_relative "service/convenience_constructors"
require_relative "service/exception_formatting"
require_relative "clock"

module RG
  class Service
    extend ConvenienceConstructors
    extend ExceptionFormatting

    # This allows us to declare attributes at the top of a service file
    # (which should help us notice when a given service starts having too
    # many dependencies), and it also allows us to support named
    # parameters when invoking a service.
    #
    # As of this writing, I haven't been able to get Virtus' default
    # attributes to work as described, so be sure to check that you got
    # any required parameters before proceeding...
    include Virtus.model

    # All services have a :clock attribute that can be passed on construction.
    attribute :clock, Clock, default: :default_clock

    # If not provided, this will default to Clock.for_current_time.
    private def default_clock
      Clock.for_current_time
    end

    # Services are performed by instances, but this provides a more
    # convenient way of invoking them.
    def self.perform(**kwargs)

      result = new(**kwargs).perform

      unless result.is_a?(Service::Result)
        raise TypeError, "Expected #{self.name} to return a Service::Result, but got:\n#{result.inspect}"
      end

      return result

    rescue StandardError => e
      # TODO: figure out how to define callbacks for this sort of thing
      if defined?(Raven)
        Raven.capture_exception e
      end

      raise e
    end
  end
end
