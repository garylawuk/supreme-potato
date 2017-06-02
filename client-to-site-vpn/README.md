# Client to Site VPN Demonstration

Client to Site VPN Demonstration

## Objective

To provide demonstration code for the set up of VPN infrastructure on a public cloud.  This is intended to support client-to-site operations, not site-to-site.

As far as possible using best practices / standards for PRIME VPNs

## Prerequisites

1. Network and VPN debugging skills
2. Account with a cloud IaaS provider, in this example we use Amazon Web Services
3. Internet connected laptop or linux/unix host with access to install tools
4. Devices to test from:  Windows 10, macOS and iOS have suitable clients built in; Android requires an installed application
 
## Install terraform

For Mac OS X / macOS

```
curl https://releases.hashicorp.com/terraform/0.7.0/terraform_0.7.0_darwin_amd64.zip > terraform.zip
unzip terraform.zip
sudo rm -rf /usr/local/bin/terrafor*
sudo cp terraform /usr/local/bin
```

## Target network map

```
[ local network ] ---> [ internet ] ---> [ Cloud network ]
[ client ] --------------- IPSEC -------------- [ server ]
````

Onward connection from the server to the internet, or to the corporate WAN, are not described here.  To make this happen routing rules in the cloud provider, more VPNs/direct connections, and/or NATing on the server, would be required.

## Local network

Assumed to be within 192.168.0.0/16.  Note if it is _not_, and overlaps with the Cloud network, failures may occurr.

## Internet

Assumed to IPv4 and unfettered.  Selective blocking of ports and protocols may cause failues (eg ICMP blocking preventing MTU path discovery)

## Cloud network

Three IP ranges to consider here:

1. Corporate IP range 
2. Cloud network IP range (should be subset of 1.) from which /24 subnets are drawn
3. Client assigned IP range (should be subset of 1. not overlapping 2.) from which /24 subnets are drawn

In our demonstration the values are:

1. 10.0.0.0/8
2. 10.0.0.0/20
3. 10.0.16.0/20

each network within the ranges is /24, as we do not desire more than 250 hosts per network or server.

## Clone this repo

Clone this repo — in these instructions we’ll assume you’ve done this in a Code directory under your home directory.

## Set up AWS CLI and credentials.

Setup your aws command line tools, IAM authorisation and credentials.  This is documented by AWS. Set up a new profile (eg vpn-demo) just for this demonstration. When you’re done the following should work without error:

```
aws ec2 --profile vpn-demo describe-instances
```

You should now create and upload an ssh public key to the correct AWS region and call it ```vpn-demo```.

```
cd ~/.ssh
openssl genrsa -out vpn-demo.pem 2048
openssl rsa -in vpn-demo.pem -pubout > vpn-demo.pub
chmod 600 vpn-demo.pem
aws ec2 import-key-pair --profile vpn-demo --key-name vpn-demo --public-key-material "$(cat vpn-demo.pub |grep -v PUBLIC)"
cd
```

## Load credentials for terraform to use

```
export AWS_ACCESS_KEY_ID="$(grep -A 3 vpn-demo ~/.aws/credentials|awk '/aws_access_key_id/ {print $3}')"
export AWS_SECRET_ACCESS_KEY="$(grep -A 3 vpn-demo ~/.aws/credentials|awk '/aws_secret_access_key/ {print $3}')"
export AWS_DEFAULT_REGION="eu-central-1"
```

## Clone this repo

Clone this repo — in these instructions we’ll assume you’ve done this in a Code directory under your home directory.

## Test installation and configuration

```
cd ~/Code/client-to-site-vpn-demonstration/terraform
terraform plan 
```

Terraform should now plan what it wants to go and do in AWS.

## Edit the variables.tf

At a minimum, change the management source IP to your IP.  If you’re not sure what this is, run

```
curl ifconfig.co
```

## Build your VPN server

```
terraform apply
```

Note from this point onwards you may want to carefully look after your terraform state file.  Ways to do this include to store in S3, details [here] (http://code.hootsuite.com/how-to-use-terraform-and-remote-state-with-s3), or conventional backups, or version control.

## Get the created server details

Get the created server details and log in

```
terraform state show aws_instance.example | grep public_ip
ssh-add ~/.ssh/vpn-demo.pem
# use the public_ip not 1.2.3.4
ssh -l ubuntu 1.2.3.4
```

## Manual steps to go into user data

Initial patch run

```
sudo apt-get update
sudo apt-get -y upgrade
sudo reboot
```

Log in again...

```
ssh -l ubuntu 1.2.3.4
sudo su - root
# install software
apt-get install -y haveged tree
for i in strongswan strongswan-dbg strongswan-ike strongswan-plugin-dhcp strongswan-plugin-eap-md5 strongswan-plugin-eap-mschapv2 strongswan-plugin-eap-peap strongswan-plugin-eap-radius strongswan-plugin-eap-tls strongswan-plugin-eap-tnc strongswan-plugin-eap-ttls strongswan-plugin-gmp strongswan-plugin-ldap strongswan-plugin-mysql strongswan-plugin-openssl strongswan-plugin-pkcs11 strongswan-plugin-radattr strongswan-plugin-sql strongswan-plugin-sqlite strongswan-plugin-unbound strongswan-pt-tls-client strongswan-starter strongswan-tnc-base strongswan-tnc-client strongswan-tnc-pdp strongswan-tnc-server strongswan-ikev1 strongswan-ikev2 strongswan-nm strongswan-plugin-af-alg strongswan-plugin-agent strongswan-plugin-attr-sql strongswan-plugin-certexpire strongswan-plugin-coupling strongswan-plugin-curl strongswan-plugin-dnscert strongswan-plugin-dnskey strongswan-plugin-duplicheck strongswan-plugin-eap-aka strongswan-plugin-eap-aka-3gpp2 strongswan-plugin-eap-dynamic strongswan-plugin-eap-gtc strongswan-plugin-eap-sim strongswan-plugin-eap-sim-file strongswan-plugin-eap-sim-pcsc strongswan-plugin-eap-simaka-pseudonym strongswan-plugin-eap-simaka-reauth strongswan-plugin-eap-simaka-sql strongswan-plugin-error-notify strongswan-plugin-farp strongswan-plugin-fips-prf strongswan-plugin-gcrypt strongswan-plugin-ipseckey strongswan-plugin-kernel-libipsec strongswan-plugin-led strongswan-plugin-load-tester strongswan-plugin-lookip strongswan-plugin-ntru strongswan-plugin-pgp strongswan-plugin-pubkey strongswan-plugin-soup strongswan-plugin-sshkey strongswan-plugin-systime-fix strongswan-plugin-unity strongswan-plugin-whitelist strongswan-plugin-xauth-eap strongswan-plugin-xauth-generic strongswan-plugin-xauth-noauth strongswan-plugin-xauth-pam strongswan-tnc-ifmap
do
    apt-get -y install "${i}"
done
# improve entropy
/etc/init.d/haveged restart

# create server keys and certs
# warning! some of these files are extremely sensitive -- handle with care
cd /etc/ipsec.d/
mkdir -p private
mkdir -p cacerts
mkdir -p certs
mkdir -p p12

ipsec pki --gen --type rsa  --size 4096 --outform der > private/strongswanKey.der
ipsec pki --gen --type ecdsa --size 256 --outform der > private/strongswanECDSAKey.der
chmod 600 private/*.der

ipsec pki --self --ca --lifetime 3650 --in private/strongswanKey.der --type rsa --dn "C=GB, O=alphagov, CN=strongSwan RSA Root CA" --outform der > cacerts/strongswanCert.der
ipsec pki --self --ca --lifetime 3650 --in private/strongswanECDSAKey.der --type ecdsa --digest sha256 --dn "C=GB, O=alphagov, CN=strongSwan ECDSA Root CA" --outform der > cacerts/strongswanECDSACert.der

ipsec pki --gen --type rsa --size 4096 --outform der > private/vpnHostKey.der
ipsec pki --gen --type ecdsa --size 256 --outform der > private/vpnHostECDSAKey.der

chmod 600 private/*.der

ipsec pki --pub --in private/vpnHostKey.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=GB, O=alphagov, CN=vpn.gov.uk" --san vpn.gov.uk --san 1.2.3.4  --san @1.2.3.4 --flag serverAuth --flag ikeIntermediate --outform der > certs/vpnHostCert.der

ipsec pki --pub --in private/vpnHostECDSAKey.der --type ecdsa | ipsec pki --issue --lifetime 730 --digest sha256 --cacert cacerts/strongswanECDSACert.der --cakey private/strongswanECDSAKey.der --dn "C=GB, O=alphagov, CN=vpn.gov.uk" --san vpn.gov.uk --san 1.2.3.4  --san @1.2.3.4 --flag serverAuth --flag ikeIntermediate --outform der > certs/vpnHostECDSACert.der

ipsec pki --gen --type rsa --size 2048 --outform der > private/UserKey.der
ipsec pki --gen --type ecdsa --size 256 --outform der > private/UserECDSAKey.der

# create a single user key for demo purposes
chmod 600 private/User*.der

ipsec pki --pub --in private/UserKey.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=GB, O=alphagov, CN=user@department.gov.uk" --san "user@department.gov.uk" --outform der > certs/UserCert.der

ipsec pki --pub --in private/UserECDSAKey.der --type ecdsa| ipsec pki --issue --lifetime 730 --digest sha256 --cacert cacerts/strongswanECDSACert.der --cakey private/strongswanECDSAKey.der --dn "C=GB, O=alphagov, CN=user@department.gov.uk" --san "user@department.gov.uk" --outform der > certs/UserECDSACert.der

# convert keys and certs to PEMs 
openssl x509 -inform DER -in cacerts/strongswanCert.der -out cacerts/strongswanCert.pem -outform PEM
openssl x509 -inform DER -in cacerts/strongswanECDSACert.der -out cacerts/strongswanECDSACert.pem -outform PEM
openssl x509 -inform DER -in certs/UserCert.der -out certs/UserCert.pem -outform PEM
openssl x509 -inform DER -in certs/UserECDSACert.der -out certs/UserECDSACert.pem -outform PEM
openssl x509 -inform DER -in certs/vpnHostCert.der -out certs/vpnHostCert.pem -outform PEM
openssl x509 -inform DER -in certs/vpnHostECDSACert.der -out certs/vpnHostECDSACert.pem -outform PEM
openssl rsa -inform DER -in private/strongswanKey.der -out private/strongswanKey.pem -outform PEM
openssl ec -inform DER -in private/strongswanECDSAKey.der -out private/strongswanECDSAKey.pem -outform PEM
openssl rsa -inform DER -in private/UserKey.der -out private/UserKey.pem -outform PEM
openssl ec -inform DER -in private/UserECDSAKey.der -out private/UserECDSAKey.pem -outform PEM
openssl rsa -inform DER -in private/vpnHostKey.der -out private/vpnHostKey.pem -outform PEM
openssl ec -inform DER -in private/vpnHostECDSAKey.der -out private/vpnHostECDSAKey.pem -outform PEM

chmod 600 private/*pem
chmod 600 certs/*pem
chmod 600 cacerts/*pem

# package up for easy distribution
# warning! the p12 file has a weak passphrase and contains private key material -- handle with care
openssl pkcs12 -export -inkey private/UserKey.pem -in certs/UserCert.pem -name "User RSA VPN Certificate" -certfile cacerts/strongswanCert.pem -caname "strongSwan RSA Root CA"   -passout pass:secret -out p12/UserRSA.p12

openssl pkcs12 -export -inkey private/UserECDSAKey.pem -in certs/UserECDSACert.pem -name "User ECDSA VPN Certificate" -certfile cacerts/strongswanECDSACert.pem -caname "strongSwan ECDSA Root CA"  -passout pass:secret -out p12/UserECDSA.p12
```

At this point collect a copy of the p12/UserECDSA.p12 files and cacerts/strongswanECDSACert.pem

```
# configure the server
cat > /etc/ipsec.conf << EOF
# ipsec.conf - strongSwan IPsec configuration file

config setup
    charondebug="ike 4, knl 4, cfg 4, net 4, esp 4, dmn 4,  mgr 4"
    uniqueids = never

conn %default
    dpdaction=clear
    dpddelay=35s
    dpdtimeout=300s
    keyexchange=ikev2
    rekey=no
    compress=yes
    fragmentation=yes
    left=%any
    leftauth=pubkey
    leftsendcert=always
    leftid=vpn.gov.uk
    leftsubnet=0.0.0.0/0
    right=%any
    rightauth=pubkey
    rightsourceip=10.0.16.0/24
    rightdns=8.8.8.8,8.8.4.4

conn IPSec-IKEv2-EAP-ECDSA
    keyexchange=ikev2
    ike=aes256-sha384-ecp384-prfsha384,aes128-sha256-ecp256-prfsha256!
    esp=aes256gcm16,aes128gcm16!
    left=%any
    leftauth=pubkey
    leftsendcert=always
    leftcert=vpnHostECDSACert.der
    rightauth=eap-tls
    rightsendcert=never
    eap_identity=%any
    right=%any
    auto=add

conn IPSec-IKEv2-ECDSA
    keyexchange=ikev2
    ike=aes256-sha384-ecp384-prfsha384,aes128-sha256-ecp256-prfsha256!
    esp=aes256gcm16,aes128gcm16!
    leftcert=vpnHostECDSACert.der
    leftsubnet=0.0.0.0/0
    right=%any
    rightsourceip=10.0.16.0/24
    auto=add
EOF

# Commented out option to use RSA, ECDSA is prefered
# echo ': RSA vpnHostKey.pem' >> /etc/ipsec.secrets
echo ': ECDSA vpnHostECDSAKey.pem' >> /etc/ipsec.secrets

```

## Configure NATing & forwarding

Configure NATing and forwarding on the server:

```
cat << 'EOF' > /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

for vpn in /proc/sys/net/ipv4/conf/*
do
    echo 0 > "${vpn}"/accept_redirects
    echo 0 > "${vpn}"/send_redirects
done
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 10.0.0.100
iptables -A INPUT -p udp --dport 500 --j ACCEPT
iptables -A INPUT -p udp --dport 4500 --j ACCEPT
iptables -A INPUT -p esp -j ACCEPT
exit 0
EOF
chmod +x /etc/rc.local
/etc/rc.local
```

## Configure Windows 10

To configure a laptop running Windows 10

1. install certificates from p12 in machine client  
2. install certificates from p12 in trusted roots
3. configure .xml
4. run powershell
5. hit VPN button

More complete instructions are in the clients folder of this repository.

## Configure Mac OS X 10.11

To configure a laptop running macOS

1. create profile with embedded certificates
2. install profile

More complete instructions are in the clients folder of this repository.

## Configure Apple iOS 9.x

To configure a laptop running macOS

1. create profile with embedded certificates (requires a device running macOS)
2. install profile

More complete instructions are in the clients folder of this repository.

## Finished?

```
terraform destroy
```

Does exactly what it says on the tin -- so maybe be really careful if you have access to more than one AWS account, environment or VPC.

## Next steps

This repository provides a quick-and-dirty VPN endpoint demonstrating the use of IKEv2 and ECDSA.  You may want to consider:

0. Port the server to OpenBSD
0. Remove the steps described above and put them in userdata.
1. Done ---Improve the hash used in the signing the PKI certs.---
2. Extending the terraform code to create three network interfaces on the server: Management (on public initially, with the ssh security group), Public and Private -- the fix up the server config to only listen for ssh on management; only listen for IPSEC on Public.
2. Done ---Extending the terraform code to enable NATing clients connecting to the VPN to enable through connections to the Internet or elsewhere.---
3. Extending the terraform code to create a more complete network, including a connection to a corporate environment.
4. Creating more than one VPN endpoint and load sharing using DNS round-robin.  Strongswan will need it's configuration syncing in some fashion across multiple nodes, ideally to support future autoscaling.
5. Connecting to and trusting corporate PKI rather than using the on-VPN self-signed self-issued demonstration examples.  CRLs should be checked.
6. Using an MDM and/or group policy to push out certificates, policies and profiles.
7. Pushing out monitoring metrics / alerts from the server(s).
8. Wrapping server(s) in autoscale mechanism.
9. Try this approach with other cloud providers
10. Try this approach with other VPN software/appliances -- Richard wants to do Cisco first!

## Thanks
- https://wiki.strongswan.org/projects/strongswan/wiki/Win7MultipleConfig
- https://wiki.strongswan.org/projects/strongswan/wiki/AppleIKEv2Profile
- https://www.zeitgeist.se/2013/11/22/strongswan-howto-create-your-own-vpn/
- https://github.com/trailofbits/algo
- https://hub.zhovner.com/geek/universal-ikev2-server-configuration/
- https://raymii.org/s/tutorials/IPSEC_vpn_with_Ubuntu_15.04.html
- https://github.com/jethrocarr/puppet-roadwarrior
- https://www.cesg.gov.uk/guidance/network-encryption-official
