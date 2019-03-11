# Inspec test for recipe chef_postfix_redis::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w[redis python2-pip epel-release].each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

describe user('sender') do
  it { should exist }
  its('shell') { should eq '/sbin/nologin' }
end

%w[postfix redis].each do |service|
  describe systemd_service(service) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

%w[25 6379].each do |port|
  describe port(port) do
    its('protocols') { should include 'tcp' }
    it { should be_listening }
    its('addresses') { should_not include '0.0.0.0' }
    its('addresses') { should include '127.0.0.1' }
  end
end

describe file('/opt/pipe_script/pipe.py') do
  its('owner') { should eq 'sender' }
  it { should be_executable }
  its('mode') { should cmp '0700' }
end

script = <<-SCRIPT
  yum install mailx -y -q
  echo 'test_message' |  mail -s 'test_subject' sender@localhost
  sleep 1
SCRIPT
# sleep is needed, as seems like redis or postfix are slow on initial responce

describe bash(script) do
  its('exit_status') { should eq 0 }
end

script = <<-SCRIPT
  redis-cli Lrange 'sender@localhost' 0 -1 | less | grep -i 'Subject' | wc -l
SCRIPT

describe bash(script) do
  its('exit_status') { should eq 0 }
  its('stdout') { should cmp 1 }
end
