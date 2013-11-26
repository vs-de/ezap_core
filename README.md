#Ezap Core

Ezap Core Gem for Ezap distributed service system.
The JetPack-fuel comes from zeromq, redis and MessagePack.

Currently it should only be used inside a save network, encryption&auth will be added to allow transport over untrusted networks(/just filter the configured ports).

## Installation

### Prerequisites

  **zeromq** your nodes should have either all v2.2.x or all v3.2.x:
  http://zeromq.org/
 
  **redis** (optional, maybe become a hard-dependency soon)
  http://redis.io/

### Fetch it
Add this line to your application's Gemfile:

    gem 'ezap_core', git: 'https://github.com/vs-de/ezap_core.git'

And then execute:

    $ bundle

## Usage

Ezap is constantly reviewed and extended by my humble self.
Usage will be demonstrated increasingly in the [demos](https://github.com/vs-de/ezap_demos)-repos.

To start ezap just run this(be="bundle exec"):
    
    $ be ezap s
    
test if ezap is running([g]lobal [m]aster [p]ing):

    $ be ezap gmp

some help

    $ be ezap help

here are already some lines about the new config argument for now:

    $ be ezap help config
    $ be ezap config dump x.yml

review and adjust the file, then
    
    $ be ezap config apply x.yml

this saves the config permanently and will be loaded next time:
    
    $ be ezap config store

(now u can delete x.yml)

to stop ezap use:

    $ be ezap h
    
please look into [ezap_demos](https://github.com/vs-de/ezap_demos.git) for an example and more info

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
