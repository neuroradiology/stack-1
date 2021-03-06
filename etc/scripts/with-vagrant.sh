#!/usr/bin/env bash
#TODO: move this logic into release.hs.
set -xe
cd "$(dirname "$0")/../.."
#TODO: set up gpg-agent forwarding for package signing (see http://superuser.com/questions/161973/how-can-i-forward-a-gpg-key-via-ssh-agent).
mkdir -p dist
gpg --export-secret-keys --armor dev@fpcomplete.com >dist/gpg-secret-key.asc
cd "etc/vagrant/$1"

# Double 'vagrant up' is a workaround for FreeBSD
vagrant up || true
vagrant up

vagrant provision
vagrant rsync
vagrant ssh -c "$3 export GITHUB_AUTH_TOKEN=$GITHUB_AUTH_TOKEN; export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID; export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY; export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION; export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN; gpg --import /vagrant/dist/gpg-secret-key.asc; cd /vagrant && (cd etc/scripts && stack --install-ghc build) && \$(cd etc/scripts && stack exec which stack-release-script) --no-test-haddocks $2"
vagrant halt
