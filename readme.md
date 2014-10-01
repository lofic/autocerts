## About

These are some scripts to ease the creation and deployment of SSL key pairs for
various services on puppet nodes.

Example of use case : deploy unique keys for some nodes to communicate with rabbitmq SSL.

You can use the ruby classes provided in hooks to create the keys on demand when
a node agent requests a catalog on the puppet master (i.e. with the certname in node.rb
if you use The Foreman as an external node classifier).

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


