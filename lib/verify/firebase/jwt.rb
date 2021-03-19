require_relative "jwt/version"

# https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library
# https://github.com/jwt/ruby-jwt (Search for RS256)

require "jwt"

class FirebaseAuth
  class InvalidTokenError < StandardError; end
  class FetchCertificatesError < StandardError; end

  def initialize(project_id)
    @project_id = project_id
  end

  def uid(firebase_jwt)
    _, header = JWT.decode(firebase_jwt, key=nil, verify=false, options={})

    certificates = fetch_certificates_from_google()
    public_key = OpenSSL::X509::Certificate.new(certificates[header["kid"]]).public_key

    # https://github.com/jwt/ruby-jwt/blob/master/lib/jwt/default_options.rb
    options = {
      algorithms: header["alg"],
      verify_expiration: true,
      verify_iat: true,
      aud: @project_id, verify_aud: true,
      iss: "https://securetoken.google.com/#{@project_id}", verify_iss: true,
      verify_not_before: false,
      verify_jti: false,
      verify_sub: false,
      leeway: 0
    }
    payload, _ = JWT.decode(firebase_jwt, key=public_key, verify=true, options)
    uid = payload["sub"]

    # uid is 1~128 characters: https://firebase.google.com/docs/auth/admin/manage-users#create_a_user
    raise InvalidTokenError.new("Invalid sub") if uid.length < 1 || uid.length > 128
    raise InvalidTokenError.new("Invalid auth_time") if Time.zone.at(payload["auth_time"]).future?
    uid
  end

  private

  def fetch_certificates_from_google()
    certificates = Rails.cache.read("firebase_auth_certificates")
    return certificates if certificates.present?

    uri = URI.parse("https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri.path)
    certificates = JSON.parse(response.body)

    error = certificates["error"]
    raise FetchCertificatesError.new(error) if error.present?

    expires_at = Time.zone.parse(response.header["expires"])
    Rails.cache.write("firebase_auth_certificates", certificates, expires_in: expires_at - Time.current)

    certificates
  end
end
