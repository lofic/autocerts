#!/usr/bin/ruby

require 'ca' # Class CertificateAuthority
#require_relative 'ca'
require 'fileutils'

FileUtils.mkdir_p('ca')

passphrase = 'Louis was here'
caname = '/CN=carabbit/O=Example lab/C=FR/ST=IDF/L=Paris'
ca=CertificateAuthority.new(caname, passphrase)
abort 'Already there' if File.exists? 'ca/ca_cert.pem'
open 'ca/ca_key.pem',  'w', 0400 do |io| io.write ca.ca_key_pem  end
open 'ca/ca_cert.pem', 'w'       do |io| io.write ca.ca_cert_pem end
puts 'OK'
