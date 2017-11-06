set :ssh_options, port: 9022

server "ec2-54-218-40-59.us-west-2.compute.amazonaws.com", user: "discourse", roles: %(app)
