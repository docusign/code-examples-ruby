def ComputeHash(secret, payload)
  require 'openssl'
  require 'base64'

  digest  = OpenSSL::Digest.new('sha256')
  hashBytes = OpenSSL::HMAC.digest(digest, secret, payload)
  base64Hash = Base64.encode64(hashBytes)
  return base64Hash;
end

def HashIsValid(secret, payload, signature)
  ver = ComputeHash(secret, payload)
  OpenSSL.secure_compare(ver.chomp, signature)
end

secret = 'xxoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxGE=' # Replace this value with your own secret
signature = 'c60xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxew=' # Replace this value with your own signature
payload = File.read('payload.txt') # Read the payload from a file named payload.txt
puts HashIsValid(secret, payload, signature) # should return true for valid