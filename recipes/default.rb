#
# Cookbook Name:: cassandra
# Recipe:: default
#
# Copyright 2012, Time Intermedia
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"

version = node['cassandra-bin']['version']

remote_file "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz" do
  source "#{node['cassandra-bin']['url']}/#{version}/apache-cassandra-#{version}-bin.tar.gz"
  not_if {::File.exists?("/usr/local/apache-cassandra-#{version}")}
  notifies :run, "script[install cassandra]", :immediately
end

script "install cassandra" do
  interpreter "bash"
  user "root"
  cwd "/usr/local"
  code <<-EOH
    tar xzf #{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz
  EOH
  action :nothing
  notifies :create, "template[/usr/local/apache-cassandra-#{version}/conf/cassandra.yaml]"
end

template "/etc/init.d/cassandra" do
  source "init.d-script.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(
    :cassandra_version => version
  )
end

template "/usr/local/apache-cassandra-#{version}/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {::File.exists?("/usr/local/apache-cassandra-#{version}")}
  notifies :restart, "service[cassandra]"
end

service "cassandra" do
  action [:enable, :start]
  supports :restart => true
end

file "cassandra-tarball-cleanup" do
  path "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz"
  action :delete
end
