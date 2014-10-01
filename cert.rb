#!/usr/bin/ruby

require 'openssl'

class SignedCertificate
    attr_reader :key, :csr, :cert

    def initialize(ca_key, ca_cert, subject)

    @key = OpenSSL::PKey::RSA.new 2048

    @csr = OpenSSL::X509::Request.new
    @csr.version = 0
    @csr.subject = OpenSSL::X509::Name.parse(subject) 
    @csr.public_key = key.public_key
    @csr.sign key, OpenSSL::Digest::SHA1.new

    @cert = OpenSSL::X509::Certificate.new
    @cert.serial  = 0
    @cert.version = 2
    @cert.not_before = Time.now
    @cert.not_after  = Time.now + (365 * 10 * 24 * 3600) # 10 years 
    @cert.subject    = @csr.subject
    @cert.public_key = @csr.public_key
    @cert.issuer     = ca_cert.subject

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = @cert
    ef.issuer_certificate  = ca_cert

    @cert.add_extension ef.create_extension('basicConstraints', 'CA:FALSE')
    @cert.add_extension ef.create_extension('keyUsage',
                            'keyEncipherment,dataEncipherment,digitalSignature')
    @cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash')
    @cert.sign ca_key, OpenSSL::Digest::SHA1.new
    end

end

