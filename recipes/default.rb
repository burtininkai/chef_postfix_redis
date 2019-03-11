#
# Cookbook:: chef_postfix_redis
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package 'epel-release'
package %w[redis python2-pip] do
  only_if "rpm -qa | grep -q \'epel-release\'"
end

systemd_unit 'redis' do
  action %i[start enable]
end

user 'sender' do
  shell '/sbin/nologin'
  comment 'user to run redis export script by postfix'
end

directory node['postfix_redis']['script_path'] do
  owner node['postfix_redis']['user']
end

cookbook_file "#{node['postfix_redis']['script_path']}/pipe.py" do
  source 'pipe.py'
  owner node['postfix_redis']['user']
  mode '700'
end

node['postfix_redis']['script_reqs'].each do |package|
  execute 'install script reqs' do
    action :run
    command "pip install #{package}"
    not_if "pip list | grep -q #{package}"
  end
end
