# frozen_string_literal: true

require 'openssl'
require 'base64'

class Connect::Eg001ValidateWebhookMessageService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  #ds-snippet-start:Connect1Step1
  def worker
    digest = OpenSSL::Digest.new('sha256')
    hashBytes = OpenSSL::HMAC.digest(digest, args[:secret], args[:payload])
    Base64.encode64(hashBytes)
  end

  def hash_valid?
    hash = worker(args[:secret], args[:payload])
    OpenSSL.secure_compare(hash.chomp, args[:signature])
  end
  #ds-snippet-end:Connect1Step1
end
