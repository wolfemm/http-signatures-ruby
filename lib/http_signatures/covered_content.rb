# frozen_string_literal: true

require "forwardable"

module HttpSignatures
  class CoveredContent
    extend ::Forwardable

    class IllegalHeader < HttpSignatures::Error
      def initialize(names)
        names_string = names.map { |n| "'#{n}'" }.join(", ")
        super("Header #{names_string} not permitted")
      end
    end

    class EmptyCoveredContent < HttpSignatures::Error; end

    SEPARATOR = " "

    REQUEST_TARGET = "(request-target)"

    # Are these useful and will they continue to be in the spec?
    CREATED = "(created)"
    EXPIRES = "(expires)"

    # Cannot sign the signature header
    ILLEGAL = ["signature"]

    def self.from_string(string)
      new(string.split(SEPARATOR))
    end

    def initialize(names)
      @names = names.map(&:downcase)
      validate_names!
    end

    def to_a
      @names.dup
    end

    def to_s
      @_string ||= @names.join(SEPARATOR)
    end

    def include?(value)
      @names.include?(value.downcase)
    end

    def_delegator :@names, :map
    def_delegator :@names, :count

    private

    def validate_names!
      raise EmptyCoveredContent if @names.empty?

      raise IllegalHeader, illegal_headers_present if illegal_headers_present.any?
    end

    def illegal_headers_present
      @_illegal_headers_present ||= ILLEGAL & @names
    end
  end
end
