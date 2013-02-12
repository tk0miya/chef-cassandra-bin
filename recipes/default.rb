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

service "cassandra" do
  supports :restart => true
  action :nothing
end

template "/usr/local/apache-cassandra-#{version}/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {::File.exists?("/usr/local/apache-cassandra-#{version}/conf")}
  notifies :restart, "service[cassandra]"
end

template "/etc/init.d/cassandra" do
  source "init.d-script.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(
    :cassandra_version => version
  )
  notifies :enable, "service[cassandra]", :immediately
  notifies :restart, "service[cassandra]"
end

script "install cassandra" do
  interpreter "bash"
  only_if {::File.exists?("#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz")}
  user "root"
  cwd "/usr/local"
  code <<-EOH
    tar xzf #{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz
  EOH
  action :nothing
  notifies :create, "template[/usr/local/apache-cassandra-#{version}/conf/cassandra.yaml]", :immediately
  notifies :create, "template[/etc/init.d/cassandra]", :immediately
  notifies :restart, "service[cassandra]", :immediately
end

remote_file "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz" do
  source "#{node['cassandra-bin']['url']}/#{version}/apache-cassandra-#{version}-bin.tar.gz"
  not_if {::File.exists?("/usr/local/apache-cassandra-#{version}")}
  notifies :run, "script[install cassandra]", :immediately
end

file "cassandra-tarball-cleanup" do
  path "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz"
  action :delete
end
