## About

These are some scripts to ease the creation and deployment of SSL key pairs for
various services on puppet nodes.

Example of use case : deploy unique keys for some nodes to communicate with rabbitmq SSL.

You can use your own CA (see examples/genca.rb) or you can reuse the Puppet CA (check
 `/var/lib/puppet/ssl/ca/` on your Puppet `ca_server`)

You can use the ruby classes provided here in hooks to create the keys on demand when
a node agent requests a catalog on the puppet master (i.e. with the certname=node name
in node.rb if you use The Foreman as an external node classifier).

## Example of use

In the fileserver.conf of the puppet master, some mount points :

```
[priv]
path /etc/puppet/fileserver/priv/%H
allow *

[pub]
path /etc/puppet/fileserver/pub
allow *
```

In a puppet module we deploy some SSL keys :

```
file { "/path/to/${::fqdn}.cert.pem" :
         source  => "puppet:///pub/themodule/${::fqdn}.cert.pem",
         mode    => '0444',
}

file { "/path/to/${::fqdn}.priv.pem" :
         source  => "puppet:///priv/themodule/${::fqdn}.priv.pem",
         mode    => '0444',
}
```

If needed, create a CA, example : `genca.rb`

Deploy some signed certificates and keys, example : `gencert.rb`

Deploy some self-signed certificates and keys, example : `genautocert.rb`

## Use case with puppet and the Foreman

You can use the ruby classes provided here in hooks to create the keys on demand when
a node agent requests a catalog on the puppet master (i.e. with the certname in node.rb
if you use The Foreman as an external node classifier).

Foreman can act as a classifier to Puppet through the External Nodes interface.
This is a mechanism provided by Puppet to ask for configuration data from an external
service, via a script (i.e. node.rb) on the puppetmaster.

When a node does a request for a catalog, `node.rb` is called.

```
                                        +--------------+   - Web UI
      +------------------------------>  | The Foreman  |   - External Node Classifier
      |             +---------------->  |              |   - Puppet Certificate Authority
      |             |                   +--------------+                               ^
      |             |                           ^                                      |
      | Smart Proxy |               Smart Proxy | - Get ENC (with node.rb)             |
      |             |                           | - Push reports                       |
      |             |                   +--------------+                               |
      |             |                   | Puppet Master| - Compile node    - Request & |
(Puppet Master (Puppet Master           |              |   catalogs          check     |
    Ter)           Bis)  ^              +--------------+                     certif.   |
                         |                     ^    ^                                  |
                         +----+                |    |                                  |
                              |                |    +-----------+                      |
                              |                |                | - Get catalog        |
                              |                |                |                      |
                       +------------+    +------------+    +------------+              |
                       | Node with  |    | Node with  |    | Node with  |              |
                       | Pup. agent |    | Pup. agent |    | Pup. agent | -------------+
                       +------------+    +------------+    +------------+

```

In node.rb we add a function that checks for the presence of keys for a
pair node+specific puppet module. So we can set multiple keys used in different
puppet modules.

If the keys are not already set, the function creates them on the fly.

This is done before applying the catalog to the node, so you don't need 2 puppet runs
for the availability of the keys.

Example below.

Edit node.rb

```ruby
SETTINGS = {
# (...)
}

# Add this :
require '/etc/puppet/gencert.rb'


# (...)

# Actual code starts here

if __FILE__ == $0 then
  # (...)
  begin
    no_env = ARGV.delete("--no-environment")
    if ARGV.delete("--push-facts")
      # push all facts files to Foreman and don't act as an ENC
      upload_all_facts
    else
      certname = ARGV[0] || raise("Must provide certname as an argument")

      # Add this function (adapt the paths and the module name):
      Gencert.createkey(certname, 'modulename', '/etc/puppet/fileserver/priv',
                        "/CN=#{certname}/O=Example Lab/C=FR/ST=IDF/L=Paris",
                        '/etc/puppet/autocerts/myca/ca_key.pem' ,
                        '/etc/puppet/autocerts/myca/ca_cert.pem',
                        'CA passphrase, empty string if there is no passphrase i.e. puppet CA')
      # (...)
    end
   # (...)
  end
end
```



