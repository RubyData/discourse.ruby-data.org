include_middleware "docker"
include_middleware "aws-cli"

execute "usermod -a -G docker discourse"
