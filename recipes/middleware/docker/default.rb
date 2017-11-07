package 'apt-transport-https'
package 'ca-certificates'
package 'curl'
package 'software-properties-common'

execute 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'
execute 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
execute 'apt-get update'

package 'docker-ce'
