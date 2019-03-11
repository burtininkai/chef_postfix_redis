default['postfix_redis'] = {
  'user' => 'sender',
  'script_path' => '/opt/pipe_script',
  'script_reqs' => ['redis']
}

normal['postfix'] = {
  'master' => {
    'relay' => {
      'active' => false
    },
    'local' => {
      'comment' => 'Store all received mails in redis',
      'command' => 'pipe',
      'args' => [
        "flags=Rq user=sender argv=#{node['postfix_redis']['script_path']}/pipe.py ${original_recipient}"
      ]
    }
  }
}
