require "rg/service/version"
require "rg/clock"
require "virtus"

module RG
  class Service
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
      result
    rescue StandardError => e
      # TODO: figure out how to define callbacks for this sort of thing
      if defined?(Raven)
        Raven.capture_exception e
      end

      raise e
    end

    # Some services may need to return success/failure results with
    # additional information.  They may use this to do so.
    class Result
      include Virtus.model
      attribute :status,  Symbol
      attribute :message, String
      attribute :object
      attribute :data,    Hash
      attribute :errors,  Array[String]

      VALID_STATUSES = [
        :success,
        :failure,
      ]

      def initialize(**kwargs)
        unless VALID_STATUSES.include?(kwargs[:status])
          fail ArgumentError, "The :status attribute must be one of: #{VALID_STATUSES.inspect}"
        end

        super # hey, don't overlook this ;)

        # If given a (non-nil) object: arg, put it in #data[:object]
        if object.present?
          data[:object] ||= object
        end

        # Always make sure there's a :status field in #data
        data[:status] ||= friendly_status
      end

      def success? ; :success == status ; end
      def failure? ; :failure == status ; end

      def description
        "%<status>s:\n%<message>s" % {
          status: friendly_status,
          message: message,
        }
      end

      private

      def friendly_status
        status.to_s.capitalize
      end
    end

    # BEGIN Convenience constructors for service results
    def self.success(message: nil, object: nil, data: {}, errors: [])
      ::RG::Service::Result.new( status: :success, message: message, object: object, data: data, errors: errors )
    end

    def self.disabled
      RG::Service::Result.new( status: :success )
    end

    def self.nothingtodohere(message=nil)
      RG::Service::Result.new( status: :success, message: message )
    end

    def self.failure(message: nil, object: nil, data: {}, errors: [])
      RG::Service::Result.new( status: :failure, message: message, object: object, data: data, errors: errors )
    end

  #   def self.result_from_exception(e)
  #     message = RG.format_exception(e)
  #     data = {
  #       # FIXME: consider change :error to :exception ?  # #unify-service-results
  #       error: {
  #         class:     e.class.name,
  #         msg:       e.message,
  #         backtrace: e.backtrace,
  #       },
  #       exception: e,
  #     }
  #     RG::Service::Result.new( status: :failure, message: message, data: data )
  #   end
    # END convenience constructors

  #   # Some services may need to be enabled or disabled for testing.
  #   # DRY up the boilerplate that makes this happen, so that service
  #   # classes may choose when to self-terminate as follows:
  #   #
  #   # def perform
  #   #   return if disabled?
  #   #   # side-effect-having code
  #   # end
  #   #
  #   # To turn a service on or off, call .enable! or .disable! on the
  #   # service class.  Including services will be enabled by default.
  #   module KillSwitch
  #     INCLUDING_CLASSES = []
  #
  #     mattr_accessor :all_enabled
  #     self.all_enabled = true
  #
  #     def self.included(receiver)
  #       receiver.mattr_accessor :enabled
  #
  #       receiver.extend ClassMethods
  #       receiver.extend Predicates
  #       receiver.include Predicates
  #       INCLUDING_CLASSES << receiver
  #     end
  #
  #     module ClassMethods
  #       def enable!  ; self.enabled = true  ; end
  #       def disable! ; self.enabled = false ; end
  #     end
  #
  #     module Predicates
  #       def enabled?
  #         if self.enabled.nil?
  #           self.enabled = ::Service::KillSwitch.all_enabled
  #         end
  #
  #         !!self.enabled
  #       end
  #
  #       def disabled? ; !enabled? ; end
  #     end
  #   end
  #
  #   #                       Set the global flag              Set all the services that have been loaded so far
  #   def self.disable_all! ; KillSwitch.all_enabled = false ; KillSwitch::INCLUDING_CLASSES.each(&:disable!) ; end
  #   def self.enable_all!  ; KillSwitch.all_enabled = true  ; KillSwitch::INCLUDING_CLASSES.each(&:enable!)  ; end
  end
end
