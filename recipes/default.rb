#
# Cookbook Name:: etherpad
# Recipe:: lite
#
# Copyright 2013, computerlyrik
# Modifications by OpenWatch FPC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

service_user = node['etherpad-lite']['service_user']
service_group = node['etherpad-lite']['service_group']
user_home = node['etherpad-lite']['service_user_home']
project_path = node['etherpad-lite']['project_path']

node_modules = node['etherpad-lite']['node_modules']
log_dir = node['etherpad-lite']['logs_dir']
log_file = "#{log_dir}/etherpad.log"
access_log = "#{log_dir}/access.log"
error_log = "#{log_dir}/error.log"

# System deps
case node['platform_family']
  when "debian", "ubuntu"
    packages = %w[gzip git-core curl python libssl-dev pkg-config build-essential]
  when "fedora", "centos", "rhel"
    packages = %w[gzip git-core curl python openssl-devel]
    # && yum groupinstall "Development Tools"
end
packages << 'abiword' if node['etherpad-lite']['use_abiword']
packages.each do |p|
  package p
end

include_recipe 'nodejs'
nodejs_npm 'pg'

# User/group
group service_group do
  action :create
end
user service_user do
  supports :manage_home => true
  home user_home
  gid service_group
  action :create
end

# Code and directories
git project_path do
  user service_user; group service_group
  repository node['etherpad-lite']['etherpad_git_repo_url']
  enable_submodules true
  action :sync
end

# Log dir
directory log_dir do
  owner service_user; group service_group
  recursive true
  action :create
end
# Make service log file
file access_log do
  owner service_user; group service_group
  action :create_if_missing
end
# Make service log file
file error_log do
  owner service_user; group service_group
  action :create_if_missing
end

# Settings
template "#{project_path}/settings.json" do
  owner user; group group
  variables node['etherpad-lite']
end

# API KEY
template "#{project_path}/APIKEY.txt" do
  owner service_user; group service_group
  variables node['etherpad-lite']
end if not node['etherpad-lite'][:etherpad_api_key].empty?

# Database
if Chef::Config[:solo]
  if node['etherpad-lite'][:db_password].nil?
    Chef::Application.fatal! "The db password is necessary when using Chef::Solo"
  end
else
  node.set_unless['etherpad-lite'][:db_password] = secure_password
  node.save
end

postgresql_connection = {
  :host => '127.0.0.1',
  :port => node[:postgresql][:config][:port],
  :username => 'postgres',
  :password => node[:postgresql][:password][:postgres],
}

postgresql_database_user node['etherpad-lite'][:db_user] do
  connection postgresql_connection
  password node['etherpad-lite'][:db_password]
  action :create
end
postgresql_database node['etherpad-lite'][:db_name] do
  connection postgresql_connection
  action :create
end
postgresql_database_user node['etherpad-lite'][:db_user] do
  connection postgresql_connection
  password node['etherpad-lite'][:db_password]
  database_name node['etherpad-lite'][:db_name]
  action :grant
end

# Upstart service config file
template "/etc/init/#{node['etherpad-lite']['service_name']}.conf" do
  owner service_user; group service_group
  source "upstart.conf.erb"
  variables({
    :etherpad_installation_dir => project_path,
    :etherpad_service_user => service_user,
    :etherpad_log => log_file,
  })
  action :create
  notifies :restart, "service[#{node['etherpad-lite']['service_name']}]"
end
service node['etherpad-lite']['service_name'] do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

if node['etherpad-lite']['proxy_server'] == 'nginx'
  template "#{node['nginx']['dir']}/sites-enabled/#{node['etherpad-lite']['service_name']}" do
    source "nginx.conf.erb"
    owner node['nginx']['user']
    group node['nginx']['group']
    variables({
      :domain => node['etherpad-lite']['domain'],
      :internal_port => node['etherpad-lite']['port_number'],
      :ssl_cert => node['etherpad-lite']['ssl_cert_path'],
      :ssl_key => node['etherpad-lite']['ssl_key_path'],
      :access_log => access_log,
      :error_log => error_log,
    })
    notifies :reload, "service[nginx]"
    action :create
  end
elsif node['etherpad-lite']['proxy_server'] == 'apache'
  web_app node['etherpad-lite']['service_name'] do
    enable true

    server_name node['etherpad-lite']['domain']
    proxy_ip node['etherpad-lite']['ip_address']
    proxy_port node['etherpad-lite']['port_number']
  end
  notifies :reload, "service[apache2]"
end

# Install plugins
unless node['etherpad-lite']['plugins'].empty?
  node['etherpad-lite']['plugins'].each do |plugin|
    plugin_npm_module = "ep_#{plugin}"
    npm_package plugin_npm_module do
      path project_path
      action :install_local
    end
  end

  # Hacky workaround because we can't pass a user to npm_module
  execute "chown -R #{user} #{node_modules}" do
    user "root"
    notifies :restart, "service[#{node['etherpad-lite']['service_name']}]"
  end
end

