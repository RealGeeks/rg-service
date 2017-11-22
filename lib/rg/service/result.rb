module RG
class Service

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

end
end
