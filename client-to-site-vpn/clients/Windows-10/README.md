# Configuration of a windows host

## Import certificates

Import the certificates -- your paths and passwords will be different (admin user powershell follows)

```PowerShell
$secure = ConvertTo-SecureString -String secret -AsPlainText -Force
Import-PfxCertificate -FilePath C:\Users\user\Desktop\VPN\UserECDSA.p12 -CertStoreLocation Cert:\LocalMachine\My -password $secret
Import-Certificate -FilePath C:\Users\user\Desktop\VPN\strongswanECDSACert.pem -CertStoreLocation Cert:\LocalMachine\root\
```

## Configure

You must edit the configuration file ```CPA_Configure_VPN_Client_PRIME_Settings_v2.3.xml``` to have the correct name and IP address.

## Install the VPN

Again, powershell as admin run the script

```PowerShell
 .\CPA_Configure_VPN_Client_PRIME_v2.3.ps1 -XMLPath .\CPA_Configure_VPN_Client_PRIME_Settings_v2.3.xml
 ```

If you do not define a proxy, there will be an error reported, but this will not stop the VPN operating correctly.

## Further reading

This is an extremely simple, stripped down example.  More is available from [Microsoft] (https://technet.microsoft.com/itpro/windows/keep-secure/vpn-profile-options) and [NCSC] (https://www.ncsc.gov.uk/guidance/eud-security-guidance-windows-10).
