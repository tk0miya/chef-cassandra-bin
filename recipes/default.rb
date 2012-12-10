#
# Cookbook Name:: cassandra
# Recipe:: default
#
# Copyright 2012, Time Intermedia
#
# All rights reserved - Do Not Redistribute
#

version = node['cassandra-bin']['version']

execute "cassandra restart" do
  command "/etc/init.d/cassandra restart"
  action :nothing
end

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
  notifies :run, resources(:execute => "cassandra restart")
end

template "/etc/init.d/cassandra" do
  source "init.d-script.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(
    :cassandra_version => version
  )
  notifies :enable, resources(:service => "cassandra"), :immediately
  notifies :run, resources(:execute => "cassandra restart")
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
  notifies :create, resources(:template => "/usr/local/apache-cassandra-#{version}/conf/cassandra.yaml"), :immediately
  notifies :create, resources(:template => "/etc/init.d/cassandra"), :immediately
  notifies :run, resources(:execute => "cassandra restart"), :immediately
end

remote_file "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz" do
  source "http://ftp.kddilabs.jp/infosystems/apache/cassandra/#{version}/apache-cassandra-#{version}-bin.tar.gz"
  not_if {::File.exists?("/usr/local/apache-cassandra-#{version}")}
  notifies :run, resources(:script => "install cassandra"), :immediately
end

file "cassandra-tarball-cleanup" do
  path "#{Chef::Config[:file_cache_path]}/apache-cassandra-#{version}-bin.tar.gz"
  action :delete
end
