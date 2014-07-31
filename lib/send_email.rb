def send_simple_message(user)
  RestClient.post "https://api:key-217d6e2d15892d7dedca22a219c739d4"\
  "@api.mailgun.net/v2/sandbox810ff1230c5e4d26bd01033c2824cb92.mailgun.org/messages",
  :from => "Mailgun Sandbox <postmaster@sandbox810ff1230c5e4d26bd01033c2824cb92.mailgun.org>",
  :to => user.email,
  :subject => "Hello Marco, password change",
  :text => "http://localhost:9292/users/reset-password/" + user.password_token
end