include_middleware "docker"

execute "usermod -a -G docker discourse"
