#!/bin/bash
set -x
test_github_ssh() {
	echo test_github_ssh
	# -T no tty allocation -n do not read from stdin
	ssh_works=$(ssh -n -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 )
	echo ${ssh_works} | grep -q  'successfully authenticated'
	if [ $? -ne 0 ]  ; then
		echo unable to login to git@github.com, allow agent forwarding
		exit 1
	fi
}
test_github_ssh
set -e
mkdir -p ~/src/nodeOS
cd ~/src/nodeOS
clone_or_update() {
	echo clone_or_update
	repo_dir=$1
	shift
	if [ ! -d $repo_dir ] ; then
		git clone $@ git@github.com:snowflakedb/${repo_dir}.git
	else
		(cd $repo_dir && git pull; )
	fi
}
# TODO fix sudmobules urls form http to git
# clone_or_update nodeos-scripts --recurse-submodules
# clone_or_update nodeos-scripts

install_devel_packages() {
	echo install_devel_packages
	sudo apt-get install -y zsh vim tmux tig
}
install_devel_packages

docker_install_if_notfound() {
	echo docker_install_if_notfound
	if sudo systemctl status docker ; then
		return
	fi

	set -e
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	apt-cache policy docker-ce
	sudo apt-get install -y docker-ce
	sudo systemctl status docker
	sudo usermod -aG docker $(id -un)
	set +e
}
# docker_install_if_notfound
