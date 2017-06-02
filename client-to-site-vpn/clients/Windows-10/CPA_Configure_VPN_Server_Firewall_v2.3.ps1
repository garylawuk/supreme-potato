# Copyright (c) Microsoft Corporation.  All rights reserved.
#  
# THIS SAMPLE CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# IF THIS CODE AND INFORMATION IS MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN
# CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER. 

<#
.SYNOPSIS
    Configures an IKEv2 VPN Server to limit inbound services 
.DESCRIPTION
    Configures an IKEv2 VPN Server with appropriate Windows Firewall settings for limited inbound services
.PARAMETERS None
    N/A
.NOTES
    Windows Server 2012 and Windows Server 2012 R2
.EXAMPLE
    C:\PS>.\CPA_Configure_VPN_Server_Firewall.ps1 
.VERSION
    2.3
#>

# Remove Public profile from default WWW HTTP group
Set-NetFirewallRule -DisplayGroup "World Wide Web Services (HTTP)" -Profile Domain, Private

# Remove Public profile from default Remote Access group
Set-NetFirewallRule -DisplayGroup "Remote Access" -Profile Domain, Private

# Remove Public profile from default File and Printer Sharing group
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Profile Domain, Private