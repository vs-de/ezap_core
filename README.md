#Ezap Core

Ezap Core Gem for Ezap distributed service system.
The JetPack-fuel comes from zeromq, redis and MessagePack.

TODOs:
Service & adapter gem will be published here soon, too.
Currently it should only be used inside a save network, encryption&auth will be added to allow transport over untrusted networks

## Installation

### Prerequisites

  zeromq, your nodes should have either all v2 or all v3:
  http://zeromq.org/
  redis (optional, maybe become a hard-dependency soon)
  http://redis.io/

### Fetch it
Add this line to your application's Gemfile:

    gem 'ezap_core', git: 'https://github.com/vs-de/ezap_core.git'

And then execute:

    $ bundle

## Usage

Ezap is currently reviewed and cleaned to get out of the works-for-me(/one purpose) stage.
Usage will be demonstrated with example code in 'ezap\_demos' repos soon.

but here are already some lines about the new config arg for now(be="bundle exec"):

    $ be ezap help
    $ be ezap s
    $ be ezap config dump x.yml

review and adjust the file, then
    
    $ be ezap config apply x.yml

test if ezap is running([g]lobal [m]aster [p]ing):

    $ be ezap gmp

this saves the config permanently and will be loaded next time

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
