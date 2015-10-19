#!/usr/bin/ruby

require 'openssl'

# In shell :
#openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
#     -out /tmp/$nodename.crt -keyout /tmp/$nodename.key  \
#     -subj "/CN=$nodename/O=Example lab/C=FR/ST=IDF/L=Paris"

class SelfSignedCertificate
    attr_reader :pub, :priv, :crt

    def initialize(hostname)
        @key = OpenSSL::PKey::RSA.new 2048

        subject = "/CN=#{hostname}/O=Example lab/C=FR/ST=IDF/L=Paris"

        @cert = OpenSSL::X509::Certificate.new
        @cert.version = 2
        @cert.serial = Time.now.to_i
        @cert.not_before = Time.now
        @cert.not_after = Time.now + (365 * 10 * 24 * 3600) # 10 years
        @cert.public_key =  @key.public_key
        @cert.subject = @cert.issuer = OpenSSL::X509::Name.parse(subject)

        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @cert
        ef.issuer_certificate = @cert
        @cert.extensions = [
            ef.create_extension("basicConstraints","CA:TRUE",false),
            ef.create_extension("subjectKeyIdentifier","hash")
        ]
        @cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                                "keyid:always,issuer:always")

        @cert.sign @key, OpenSSL::Digest::SHA1.new

        @pub = @key.public_key.to_pem
        @priv = @key.to_pem
        @crt = @cert.to_pem
    end

end


