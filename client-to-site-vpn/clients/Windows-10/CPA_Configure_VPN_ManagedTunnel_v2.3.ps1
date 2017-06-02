# Copyright (c) Microsoft Corporation.  All rights reserved.
#  
# THIS SAMPLE CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# IF THIS CODE AND INFORMATION IS MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN
# CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER. 

<#
.SYNOPSIS
    Configures VPN Managed Tunnel firewall rules and proxy settings
.DESCRIPTION
    Configures enforced proxy settings and Windows Firewall rules to block all outbound traffic apart from a defined list of allowed exceptions and core VPN traffic    
.PARAMETERS XMLPath
    Parameters are defined in an XML settings file
.NOTES
    Requires Windows 7 and Windows 8/8.1
.EXAMPLE
    C:\PS>.\CPA_Configure_VPN_ManagedTunnel.ps1 
.VERSION
    2.3
#>

[CmdLetBinding(DefaultParameterSetName="Default")]
param(

    [Parameter(Mandatory=$true,ParameterSetName="Default")]
    [string] $XMLPath
       
)

Function Main
{
#       
#      .DESCRIPTION  
#         Main processing function
#

        #Get Information
        $xml = [xml](get-content $XMLPath)
        $Domain = Get-ADDomain
        $strDomainDN = $Domain.distinguishedName
        $strDomainDNSRoot = $Domain.DNSRoot
        $strVPNClientFirewallPolicy  = $xml.Configuration.ClientFirewallPolicyName

	#Create VPN Managed Tunnel GPO      
        Create-GroupPolicy -newGPOName $strVPNClientFirewallPolicy

	#Prevent modification of proxy server settings
        Set-GPRegistryValue -Name $strVPNClientFirewallPolicy -Key "HKLM\Software\Policies\Microsoft\Internet Explorer\Control Panel" -ValueName "Proxy" -Type DWord -Value 1        
	
	#Configure Client Firewall Settings
        $gpo = Open-NetGPO -PolicyStore ($strDomainDNSRoot + "\" + $strVPNClientFirewallPolicy)
        SetGlobalFirewallProperties -globalFirewallProperties $xml -gpo $gpo
     
        #Create the VPN Core Rules
        Foreach ($firewallRule in $xml.Configuration.VPNCore.IPsecESP.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        Foreach ($firewallRule in $xml.Configuration.VPNCore.IPsecIKE.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        Foreach ($firewallRule in $xml.Configuration.VPNCore.IPsecNAT.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        Foreach ($firewallRule in $xml.Configuration.VPNCore.VPNIPEncapsulation.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        Foreach ($firewallRule in $xml.Configuration.VPNCore.IPv4Corp.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        Foreach ($firewallRule in $xml.Configuration.VPNCore.NCSIProbes.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }
        
        Foreach ($firewallRule in $xml.Configuration.VPNCore.CRL.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }
        
        #Create the VPN Custom Endpoints Rules
        Foreach ($firewallRule in $xml.Configuration.VPNCustom.AllowedEndpoint.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        #Create the Core Networking Rules
        Foreach ($firewallRule in $xml.Configuration.NetworkingCore.FirewallRule)
        {

            CreateFirewall-Rule -rule $firewallRule -gpo $gpo

        }

        #Save the Group Policy changes
        Save-NetGPO -GPOSession $GPO       

}

Function Create-GroupPolicy($newGPOName)
{
#       
#      .DESCRIPTION  
#         Create group policy
#  

    $error.clear()
                                   
                   try
                   {   


                        Write-host -ForegroundColor Green ("INFORMATION: Attempting to create  the Group Policy " + $newGPOName)
                        
                        New-GPO -Name $newGPOName -ErrorAction Stop | Out-Null
                        
                    }

                    Catch
                    {
        
                        If($error -match "already exists")
                        {

                            Write-Host -ForegroundColor Cyan ("INFORMATION: The Group Policy " + $newGPOName + " already exists. Policy creation skipped.")

                        }
                        Else
                        {
                        
                            Write-Host -ForegroundColor Red ("ERROR: Unable to create the policy " + $newGPOName)
     
                        }
                    }
                
                    If(!$Error)
                    {
        
                        Write-Host -ForegroundColor Green ("INFORMATION: Created the policy " + $newGPOName)
                 
                    }

        
}

Function SetGlobalFirewallProperties($globalFirewallProperties, $gpo)
{
#       
#      .DESCRIPTION  
#         Set Global Firewall Settings
#  


 $error.clear()
                                   
                   try
                   {   


                        Write-host -ForegroundColor Green ("INFORMATION: Attempting to configure global firewall properties")
                        
                        Set-NetFirewallProfile -profile Public,Private -Enabled True  -DefaultOutboundAction Block -DefaultInboundAction Block -AllowLocalFirewallRules Fals -GPOSession $gpo -ErrorAction Stop
                        Set-NetFirewallProfile -profile Domain -Enabled True -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowLocalFirewallRules False -AllowLocalIPsecRules False -GPOSession $gpo -ErrorAction Stop
                    
                    }

                    Catch
                    {
        
                        Write-Host -ForegroundColor Red ("ERROR: Unable to configure the global firewall properties in the policy " + $gpo)
     
                
                    }
                
                    If(!$Error)
                    {
        
                        Write-Host -ForegroundColor Green ("INFORMATION: Configured the global firewall properties in the policy " + $gpo)
                 
                    }
       

}
   

Function CreateFirewall-Rule($rule, $gpo)
{
#       
#      .DESCRIPTION  
#         Creates a Firewall Rule in the target Group Policy
#  


#Check if the rule already exists
If(!(Get-NetfirewallRule -GPOSession $gpo | where {$_.DisplayName -eq $rule.displayName} -ErrorAction SilentlyContinue))
{


 #Create array to handle multiple values (e.g. for Remote Addresses)
 $remoteAddressArray = @()
 $remoteaddresses = $rule.remoteaddress.split(",")

  Foreach ($remoteaddress in $remoteaddresses)
  {

    $remoteAddressArray += $remoteaddress

  }

  $error.clear()

    #If an IcmpType is configured, ensuring attribute is supplied, otherwise run without -IcmpType parameter
    If ($rule.IcmpType)
    {
          
                                   
                   try
                   {   


                        Write-host -ForegroundColor Green ("INFORMATION: Attempting to create firewall rule " + $rule.displayName)
                        
                        New-NetFirewallRule -DisplayName $rule.displayName -Description $rule.description -Program $rule.program -Service $rule.service -direction $rule.direction -Enabled $rule.enabled -Protocol $rule.protocol -IcmpType $rule.icmptype -action $rule.action -LocalPort $rule.localPort -RemotePort $rule.RemotePort -LocalAddress $rule.localaddress -RemoteAddress $remoteAddressArray -Profile $rule.profile -GPOSession $GPO -ErrorAction Stop | out-null
                        
                    }

                    Catch
                    {
        
                        Write-Host -ForegroundColor Red ("ERROR: Unable to create the firewall rule " + $rule.displayName)
     
                
                    }
                
                    If(!$Error)
                    {
        
                        Write-Host -ForegroundColor Green ("INFORMATION: Created the firewall rule " + $rule.displayName)
                 
                    }     

    

    }

    Else
    {

                   try
                   {   


                        Write-host -ForegroundColor Green ("INFORMATION: Attempting to create firewall rule " + $rule.displayName)
                        
                        New-NetFirewallRule -DisplayName $rule.displayName -Description $rule.description -Program $rule.program -Package $rule.package -Service $rule.service -direction $rule.direction -Enabled $rule.enabled -Protocol $rule.protocol -action $rule.action -LocalPort $rule.localPort -RemotePort $rule.RemotePort -LocalAddress $rule.localaddress -RemoteAddress $remoteAddressArray -Profile $rule.profile -GPOSession $GPO -ErrorAction Stop | out-null
                        
                    }

                    Catch
                    {
        
                        Write-Host -ForegroundColor Red ("ERROR: Unable to create the firewall rule " + $rule.displayName)
     
                
                    }
                
                    If(!$Error)
                    {
        
                        Write-Host -ForegroundColor Green ("INFORMATION: Created the firewall rule " + $rule.displayName)
                 
                    } 

    }

}
Else
{

Write-Host -ForegroundColor Cyan ("INFORMATION: The firewall rule " + $rule.displayName + " already exists in the Group Policy Object and will be skipped")

}

}

Function IsInRole()
{
#       
#      .DESCRIPTION  
#         Checks the user is a member of the local administrators group
#  


$user = [Security.Principal.WindowsIdentity]::GetCurrent();
(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

}


Function LoadModule([string]$name)
{ 

#       
#      .DESCRIPTION  
#         Load the specified PowerShell module
#  


    If(Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) 
    { 

        Import-Module -Name $name 
        return $true

    } 

    Else 
    { 
        return $false 
    } 
     
}


## End Functions ##

Write-Host -ForegroundColor Cyan "INFORMATION: Script Processing Started...."

If(!(IsInRole))
{

Write-Host -ForegroundColor Cyan "ERROR: The PowerShell process needs to be running elevated to continue"
Exit

}

If($host.Version.major -lt "3")
{

Write-Host -ForegroundColor Cyan "ERROR: The script requires PowerShell 3.0 and above."
Exit

}


If((Split-Path $XMLPath -parent) -eq ".")
{
Write-Host -ForegroundColor Cyan ("ERROR: The XML path provided must be the full file path E.g C:\Folder\Config.xml")
Exit
}


#Load Active Directory Module
If ((LoadModule -name ActiveDirectory) -eq $True)
{

    Write-Host -ForegroundColor Green "SUCCESS: Loaded Active Directory Module"

}
Else 
{

    Write-Host -ForegroundColor Red "ERROR: Failed to load Active Directory Module"
    Exit
    
}

#Load Group Policy Module
If ((LoadModule -name GroupPolicy) -eq $True)
{

    Write-Host -ForegroundColor Green "SUCCESS: Loaded Group Policy Module"
    

}
Else 
{

    Write-Host -ForegroundColor Red "ERROR: Failed to load Group Policy Module"
    Exit

}

#Load Network Security Module
If ((LoadModule -name NetSecurity) -eq $True)
{

    Write-Host -ForegroundColor Green "SUCCESS: Loaded Network Security Module"

}
Else 
{

    Write-Host -ForegroundColor Red "ERROR: Failed to load Network Security Module"
    Exit

}


$logSeperator = "*******************************************************************************************************"
$currentDir = (Split-Path (((Get-Variable MyInvocation).Value).mycommand.path))

Main
Set-location $currentDir

Write-Host -ForegroundColor Cyan ("INFORMATION: Script Processing Complete....")

