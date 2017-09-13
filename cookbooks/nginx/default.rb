# frozen_string_literal: true

%w[git gcc openssl-devel].each do |pkg|
  package pkg
end

execute 'groupadd nginx' do
  not_if 'cat /etc/group | grep nginx'
end

execute 'useradd -g nginx nginx' do
  not_if 'cat /etc/passwd | grep nginx'
end

include_recipe 'nginx_build'
include_recipe 'nginx_build::install'

node[:sites].each do |site|
  ['/var/log/nginx', "/var/log/nginx/#{site[:domain]}"].each do |dir|
    directory dir do
      owner 'nginx'
      group 'nginx'
      mode '0755'
    end
  end
end

template node[:nginx_build][:nginx_conf] do
  source 'templates/etc/nginx/nginx.conf.erb'
  variables({
    nginx_user: node[:nginx_build][:nginx_user],
    nginx_pid: node[:nginx_build][:nginx_pid]
  })
  owner 'root'
  group 'root'
  mode '0644'
end

%w(/etc/nginx/site-available /etc/nginx/site-enabled).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

node[:sites].each do |site|
  template "/etc/nginx/site-available/#{site[:domain]}.conf" do
    source "templates/etc/nginx/site-available/conf.erb"
    variables(
                {
                  directory: node[:wordpress][:directory],
                  server_name: site[:domain]
                }
    )
    owner 'root'
    group 'root'
    mode '0644'
  end
end

node[:sites].each do |site|
  link "/etc/nginx/site-enabled/#{site[:domain]}.conf" do
    to "/etc/nginx/site-available/#{site[:domain]}.conf"
  end
end

service 'nginx' do
  action %i[enable start]
end
