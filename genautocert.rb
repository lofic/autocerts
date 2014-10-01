#!/usr/bin/ruby

require 'fileutils'
require 'autocert' # class SelfSignedCertificate

def createkey(hostname, pupmodule, pubfolder, prvfolder)
    return 'Already there' if
        File.exist?("#{pubfolder}/#{pupmodule}/#{hostname}.cert.pem")
    key = SelfSignedCertificate.new(hostname)
    FileUtils.mkdir_p "#{pubfolder}/#{pupmodule}/"
    FileUtils.mkdir_p "#{prvfolder}/#{hostname}/#{pupmodule}/"
    open "#{pubfolder}/#{pupmodule}/#{hostname}.pub.pem",  'w' do
        |io| io.write key.pub  end
    open "#{pubfolder}/#{pupmodule}/#{hostname}.cert.pem", 'w' do
        |io| io.write key.crt  end
    open "#{prvfolder}/#{hostname}/#{pupmodule}/#{hostname}.priv.pem", 'w' do
        |io| io.write key.priv end
    'OK'
end

#FILESERVERPUB='/etc/puppet/fileserver/export'
#FILESERVERPRV='/etc/puppet/fileserver/private'
FILESERVERPUB='fileserver/export'
FILESERVERPRV='fileserver/private'

hostname='foo.example.com'
pupmodule='jboss'

puts createkey(hostname, pupmodule, FILESERVERPUB, FILESERVERPRV )


