# frozen_string_literal: true

module HttpSignatures
  module VerificationAlgorithm
    def self.create(algorithm)
      case algorithm
      when HttpSignatures::Algorithm::Hmac then Hmac.new(algorithm)
      when HttpSignatures::Algorithm::Rsa then Rsa.new(algorithm)
      when HttpSignatures::Algorithm::Hs2019 then Hs2019.new(algorithm)
      else raise UnknownAlgorithm.new(algorithm)
      end
    end

    class UnknownAlgorithm < StandardError
      def initialize(algorithm)
        super("Unknown algorithm '#{algorithm}'")
      end
    end
  end
end
