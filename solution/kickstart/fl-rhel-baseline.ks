# Fedora Lane — sample Kickstart aligned to the golden-image baseline
# PRACTICE ONLY — replace URLs, keys, and activation-key placeholders.
# Prefer Image Builder for the pilot; Kickstart is an alternate day-0 path.

#version=RHEL9
cdrom
text
reboot

lang en_US.UTF-8
keyboard us
timezone UTC --utc
network --bootproto=dhcp --device=link --activate --hostname=fl-rhel-new

# Placeholder — do not commit real activation keys
# rhsm --organization=YOUR_ORG --activation-key=YOUR_KEY

rootpw --lock
user --name=fladmin --groups=wheel --iscrypted --password=$6$REPLACE_WITH_HASH
sshkey --username=fladmin "ssh-ed25519 AAAAREPLACE_WITH_YOUR_PUBLIC_KEY fladmin@fedorlane-pilot"

firewall --enabled --service=ssh
selinux --enforcing
services --enabled=sshd,chronyd,firewalld

%packages
@^minimal-environment
vim-enhanced
curl
jq
chrony
firewalld
insights-client
cockpit
cockpit-system
openssh-server
python3
podman
%end

%post --log=/root/ks-post.log
systemctl enable sshd chronyd firewalld
# Insights register is done post-build with a real auth method — see docs/runbook-rhel-day2.md
echo "Fedora Lane baseline Kickstart complete" > /etc/motd
%end
