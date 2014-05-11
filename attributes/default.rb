#
# Cookbook Name:: etherpad-lite
# Attributes:: default
#
# Copyright 2013, OpenWatch FPC
#
# Licensed under Apache 2.0
#

# Defaults based on https://github.com/ether/etherpad-lite/blob/develop/settings.json.template

default['etherpad-lite']['etherpad_git_repo_url'] = 'git://github.com/ether/etherpad-lite.git'
default['etherpad-lite']['etherpad_api_key'] = ''

default['etherpad-lite']['title'] = "Etherpad"
default['etherpad-lite']['favicon_url'] = "favicon.ico"
default['etherpad-lite']['default_text'] = "Welcome to Etherpad!\\n\\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\\n\\nGet involved with Etherpad at http:\/\/etherpad.org\\n"

default['etherpad-lite']['domain'] = "example.com"
default['etherpad-lite']['ip_address'] = "0.0.0.0"
default['etherpad-lite']['port_number'] = 9001
default['etherpad-lite']['session_key'] = ""

default['etherpad-lite']['ssl_enabled'] = false
default['etherpad-lite']['ssl_key_path'] = ""
default['etherpad-lite']['ssl_cert_path'] = ""

default['etherpad-lite']['db_type'] = "postgres"
default['etherpad-lite']['db_user'] = "postgres"
default['etherpad-lite']['db_host'] = "localhost"
default['etherpad-lite']['db_port'] = nil
default['etherpad-lite']['db_password'] = ""
default['etherpad-lite']['db_name'] = "etherpad"

default['etherpad-lite']['admin_enabled'] = false
default['etherpad-lite']['admin_password'] = ""

default['etherpad-lite']['require_session'] = "false"
default['etherpad-lite']['require_authentication'] = "false"
default['etherpad-lite']['require_authorization'] = "false"
default['etherpad-lite']['edit_only'] =  "false"

default['etherpad-lite']['abiword_path'] = "/usr/bin/abiword"

default['etherpad-lite']['minify'] = "true"
default['etherpad-lite']['max_age'] = 21600 # // 60 * 60 * 6 = 6 hours
default['etherpad-lite']['socketTransportProtocols'] = ["websocket", "xhr-polling", "jsonp-polling", "htmlfile"],

default['etherpad-lite']['service_user'] = 'etherpad'
default['etherpad-lite']['service_user_gid'] = node['etherpad-lite']['service_user']
default['etherpad-lite']['service_user_home'] = "/home/#{node['etherpad-lite']['service_user']}"
default['etherpad-lite']['service_name'] = node['etherpad-lite']['service_user']

default['etherpad-lite']['log_level'] = "INFO"
default['etherpad-lite']['logs_dir'] = "#{node['etherpad-lite']['service_user_home']}/etherpad-lite/log"

default['etherpad-lite']['proxy_server'] = "nginx"


default['etherpad-lite']['plugins'] = []
