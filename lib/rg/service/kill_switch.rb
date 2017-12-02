module RG
class Service

  # Some services may need to be enabled or disabled for testing.
  # DRY up the boilerplate that makes this happen, so that service
  # classes may choose when to self-terminate as follows:
  #
  # def perform
  #   return if disabled?
  #   # side-effect-having code
  # end
  #
  # To turn a service on or off, call .enable! or .disable! on the
  # service class.  Including services will be enabled by default.
  module KillSwitch
    INCLUDING_CLASSES = []

    mattr_accessor :all_enabled
    self.all_enabled = true

    def self.included(receiver)
      receiver.mattr_accessor :enabled

      receiver.extend ClassMethods
      receiver.extend Predicates
      receiver.include Predicates
      INCLUDING_CLASSES << receiver
    end

    module ClassMethods
      def enable!  ; self.enabled = true  ; end
      def disable! ; self.enabled = false ; end
    end

    module Predicates
      def enabled?
        if self.enabled.nil?
          self.enabled = RG::Service::KillSwitch.all_enabled
        end

        !!self.enabled
      end

      def disabled? ; !enabled? ; end
    end
  end

  #                       Set the global flag              Set all the services that have been loaded so far
  def self.disable_all! ; KillSwitch.all_enabled = false ; KillSwitch::INCLUDING_CLASSES.each(&:disable!) ; end
  def self.enable_all!  ; KillSwitch.all_enabled = true  ; KillSwitch::INCLUDING_CLASSES.each(&:enable!)  ; end

end
end
