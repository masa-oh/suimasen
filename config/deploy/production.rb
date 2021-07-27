server "13.115.27.142",
  user: "masao",
  roles: %w{app db web},
  ssh_options: {
    port: 22,
    user: "masao", # overrides user setting above
    keys: %w(~/.ssh/suimasen_key_rsa),
    forward_agent: true,
    auth_methods: %w(publickey),
  }
