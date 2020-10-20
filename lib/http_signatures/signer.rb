# frozen_string_literal: true

require "base64"

module HttpSignatures
  class Signer
    def initialize(key, algorithm, covered_content)
      @key = key
      @algorithm = algorithm
      @covered_content = covered_content
    end

    def signature_header(message, created: nil, expires: nil)
      SignatureHeader.new(
        key_id: @key.id,
        algorithm: @algorithm.name,
        covered_content: @covered_content,
        base64_value: base64_signature(message, @covered_content, created: created, expires: expires),
        created: created,
        expires: expires
      )
    end

    def sign(request, **kwargs)
      message = Message.from(request)

      headers_target =
        case request
        when Net::HTTPGenericRequest
          request
        when defined?(ActionDispatch) && ActionDispatch::Request
          request.headers
        else
          raise ArgumentError, "Cannot sign #{raw.class}"
        end

      headers_target[Header::SIGNATURE] = signature_header(message, **kwargs).to_s

      request
    end

    private

    def base64_signature(*args)
      digest = @algorithm.sign(@key.secret, signature_input(*args).to_s)

      ::Base64.strict_encode64(digest)
    end

    def signature_input(message, covered_content, created:, expires:)
      SignatureInput.new(
        message,
        covered_content,
        created: created,
        expires: expires
      )
    end
  end
end
