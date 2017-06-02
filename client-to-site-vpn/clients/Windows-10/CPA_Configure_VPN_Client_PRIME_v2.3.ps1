# Copyright (c) Microsoft Corporation.  All rights reserved.
#  
# THIS SAMPLE CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# IF THIS CODE AND INFORMATION IS MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN
# CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER. 

<#
.SYNOPSIS
    Configures an IKEv2 VPN Connection for PRIME
.DESCRIPTION
    Configures an IKEv2 VPN Connection with appropriate connection and crypto settings to meet the PRIME profile
.PARAMETERS XMLPath
    Parameters are defined in an XML settings file
.NOTES
    Requires Windows 8.1
.EXAMPLE
    C:\PS>.\CPA_Configure_VPN_Client_PRIME.ps1 
.VERSION
    2.3
#>

[CmdLetBinding(DefaultParameterSetName="Default")]
param(

    [Parameter(Mandatory=$true,ParameterSetName="Default")]
    [string] $XMLPath
       
)

# Define parameters
$xml = [xml](get-content $XMLPath)
$strVPNName = $xml.Configuration.VPNClient.VPNName
$strVPNServerAddress = $xml.Configuration.VPNClient.VPNServerAddress
$strVPNAuthMethod = $xml.Configuration.VPNClient.VPNAuthMethod
$strVPNEncryptLevel = $xml.Configuration.VPNClient.VPNEncryptLevel
$strVPNTunnelType = $xml.Configuration.VPNClient.VPNTunnelType
$strVPNIkeSAEncrypt = $xml.Configuration.VPNClient.VPNIkeSAEncrypt
$strVPNIkeSAInteg = $xml.Configuration.VPNClient.VPNIkeSAInteg
$strVPNChildSAEncrypt = $xml.Configuration.VPNClient.VPNChildSAEncrypt
$strVPNChildSAInteg = $xml.Configuration.VPNClient.VPNChildSAInteg
$strVPNPFSGroup = $xml.Configuration.VPNClient.VPNPFSGroup
$strVPNDHGroup = $xml.Configuration.VPNClient.VPNDHGroup
$strVPNProxyServer = $xml.Configuration.VPNClient.VPNProxyServer
$strVPNProxyExceptions = $xml.Configuration.VPNClient.VPNProxyExceptions

# Create IKEv2 connectoid
Write-Host -ForegroundColor Green ("INFORMATION: Creating VPN Connection...") 
Add-VPNConnection -Name $strVPNName -ServerAddress $strVPNServerAddress -AllUserConnection -AuthenticationMethod $strVPNAuthMethod -EncryptionLevel $strVPNEncryptLevel -TunnelType $strVPNTunnelType | Out-Null

# Reset to default crypto
Write-Host -ForegroundColor Green ("INFORMATION: Resetting Default Cryptography...")
Set-VPNConnectionIPsecConfiguration -ConnectionName $strVPNName -RevertToDefault -Force | Out-Null

# Configure custom crypto
Write-Host -ForegroundColor Green ("INFORMATION: Configuring Custom Cryptography...")
Set-VPNConnectionIPsecConfiguration -ConnectionName $strVPNName –AuthenticationTransformConstants $strVPNIkeSAInteg -CipherTransformConstants $strVPNIkeSAEncrypt -EncryptionMethod $strVPNChildSAEncrypt -IntegrityCheckMethod $strVPNChildSAInteg -PfsGroup $strVPNPFSGroup -DHGroup $strVPNDHGroup -Force

# Enforce proxy usage
Set-VPNConnectionProxy -Name $strVPNName -ProxyServer $strVPNProxyServer -ExceptionPrefix $strVPNProxyExceptions -BypassProxyForLocal | Out-Null

Write-Host -ForegroundColor Cyan ("INFORMATION: Script Processing Complete....")
