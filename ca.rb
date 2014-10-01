#!/usr/bin/ruby

require 'openssl'

class CertificateAuthority
    attr_reader :cipher, :ca_cert, :ca_key, :ca_cert_pem, :ca_key_pem

    def initialize(caname, passphrase)
        @ca_key = OpenSSL::PKey::RSA.new 2048

        @cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
        
        ca_name = OpenSSL::X509::Name.parse caname
        
        @ca_cert = OpenSSL::X509::Certificate.new
        @ca_cert.serial  = 0
        @ca_cert.version = 2
        @ca_cert.not_before = Time.now
        @ca_cert.not_after  = Time.now + 86400
        @ca_cert.public_key = @ca_key.public_key
        @ca_cert.subject = ca_name
        @ca_cert.issuer  = ca_name
        
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @ca_cert
        ef.issuer_certificate  = @ca_cert
        
        @ca_cert.add_extension \
          ef.create_extension('subjectKeyIdentifier', 'hash')
        @ca_cert.add_extension \
          ef.create_extension('basicConstraints', 'CA:TRUE', true)
        @ca_cert.add_extension \
          ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true)
        
        @ca_cert.sign ca_key, OpenSSL::Digest::SHA1.new

        @ca_key_pem  = @ca_key.export(@cipher, passphrase)
        @ca_cert_pem = @ca_cert.to_pem 
    end
end

