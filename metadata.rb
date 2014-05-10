name             'etherpad-lite'
maintainer       'OpenWatch FPC'
maintainer_email 'chris@openwatch.net'
license          'Apache 2.0'
description      'Installs etherpad-lite'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

depends         'nodejs'
depends         'npm'

depends         'postgresql'

depends         'nginx'
depends         'apache2'

# Check README.md for attributes
