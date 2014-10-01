#!/usr/bin/ruby

require 'fileutils'
require 'cert' # Class SignedCertificate

def createkey(hostname, pupmodule, pubfolder, prvfolder, subject, ca_key_file,
ca_crt_file, passphrase)
    return 'Already there' if
        File.exist?("#{pubfolder}/#{pupmodule}/#{hostname}.cert.pem")
    ca_key     = OpenSSL::PKey::RSA.new File.read(ca_key_file), passphrase
    ca_cert    = OpenSSL::X509::Certificate.new File.read ca_crt_file
    c=SignedCertificate.new(ca_key, ca_cert, subject)
    FileUtils.mkdir_p "#{pubfolder}/#{pupmodule}/"
    FileUtils.mkdir_p "#{prvfolder}/#{hostname}/#{pupmodule}/"
    #open "#{pubfolder}/#{pupmodule}/#{hostname}.pub.pem",  'w' do
    #|io| io.write c.key.public_key.to_pem end
    #open "#{pubfolder}/#{pupmodule}/#{hostname}.csr.pem",  'w' do
    #|io| io.write c.csr.to_pem end
    open "#{pubfolder}/#{pupmodule}/#{hostname}.cert.pem", 'w' do
        |io| io.write c.cert.to_pem end
    open "#{prvfolder}/#{hostname}/#{pupmodule}/#{hostname}.priv.pem", 'w' do
        |io| io.write c.key.to_pem end
    'OK'
end

#FILESERVERPUB='/etc/puppet/fileserver/export'
#FILESERVERPRV='/etc/puppet/fileserver/private'
FILESERVERPUB='fileserver/export'
FILESERVERPRV='fileserver/private'

hostname    = 'bar.example.com'
pupmodule   = 'rabbitmq'
subject     = "/CN=#{hostname}/O=Example lab/C=FR/ST=IDF/L=Paris"
ca_key_file = 'ca/ca_key.pem'
ca_crt_file = 'ca/ca_cert.pem'
passphrase  = 'Louis was here'

puts createkey(hostname, pupmodule, FILESERVERPUB, FILESERVERPRV, subject,
ca_key_file, ca_crt_file, passphrase)

