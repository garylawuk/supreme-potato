function FindProxyForURL(url, host) {

    /* Normalize the URL for pattern matching */
    url = url.toLowerCase();
    host = host.toLowerCase();

    /* Don't proxy local hostnames */
    if (isPlainHostName(host)) {
        return 'DIRECT';
    }
    
    /* Don’t proxy ftp */
    if (url.substring(0, 4) == "ftp:") {
        return "DIRECT";
    }

    /* Don't proxy our domains */
    if (dnsDomainIs(host, ".example.gov.uk") ||
        (host == "example.gov.uk") ||
        dnsDomainIs(host, ".refcorp.example.gov.uk") ||
        (host == "refcorp.example.gov.uk") ||
        dnsDomainIs(host, ".corp.example.gov.uk") ||
        (host == "corp.example.gov.uk")) {
        return 'DIRECT';
    }

    /* Don't proxy Windows Update */
    if ((host == "download.microsoft.com") ||
    (host == "ntservicepack.microsoft.com") ||
    (host == "cdm.microsoft.com") ||
    (host == "wustat.windows.com") ||
    (host == "windowsupdate.microsoft.com") ||
    (dnsDomainIs(host, ".windowsupdate.microsoft.com")) ||
    (host == "update.microsoft.com") ||
    (dnsDomainIs(host, ".update.microsoft.com")) ||
    (dnsDomainIs(host, ".windowsupdate.com")))
    {
    return 'DIRECT';
    }

    if (isResolvable(host)) {
        var hostIP = dnsResolve(host);

        /* Don't proxy non-routable addresses (RFC 1918, 3330) */
        if (isInNet(hostIP, '0.0.0.0', '255.0.0.0') ||
            isInNet(hostIP, '10.0.0.0', '255.0.0.0') ||
            isInNet(hostIP, '127.0.0.0', '255.0.0.0') ||
            isInNet(hostIP, '169.254.0.0', '255.255.0.0') ||
            isInNet(hostIP, '172.16.0.0', '255.240.0.0') ||
            isInNet(hostIP, '192.0.2.0', '255.255.255.0') ||
            isInNet(hostIP, '192.88.99.0', '255.255.255.0') ||
            isInNet(hostIP, '192.168.0.0', '255.255.0.0') ||
            isInNet(hostIP, '198.18.0.0', '255.254.0.0') ||
            isInNet(hostIP, '224.0.0.0', '240.0.0.0') ||
            isInNet(hostIP, '240.0.0.0', '240.0.0.0')) {
            return 'DIRECT';
        }
        /* Go direct over PSN */
        if (
            /* Memset PSN Protected  */
            isInNet(hostIP, '5.153.248.0', '255.255.255.0') ||
            /* PSN team PSN Assured */
            isInNet(hostIP, '51.33.0.0', '255.255.0.0') ||
            /* PSN team PSN Assured */
            isInNet(hostIP, '51.130.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.231.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.238.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.239.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.242.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.243.0.0', '255.255.0.0') ||
            /* PSN team PSN Protected */
            isInNet(hostIP, '51.247.0.0', '255.255.0.0') ||
            /* Thales PSN Assured  */
            isInNet(hostIP, '109.234.170.0', '255.255.255.0') ||
            /* Thales PSN Assured  */
            isInNet(hostIP, '109.234.171.0', '255.255.255.0') ||
            /* Thales PSN Assured  */
            isInNet(hostIP, '109.234.172.0', '255.255.255.0') ||
            /* Thales PSN Protected  */
            isInNet(hostIP, '109.234.173.0', '255.255.255.0') ||
            /* Thales PSN Assured  */
            isInNet(hostIP, '109.234.174.0', '255.255.255.0') ||
            /* Thales PSN Protected  */
            isInNet(hostIP, '109.234.175.0', '255.255.255.0') ||
            /* Convergence Group PSN Assured */
            isInNet(hostIP, '137.221.131.248', '255.255.255.248') ||
            /* Convergence Group PSN Assured */
            isInNet(hostIP, '137.221.133.32', '255.255.255.248') ||
            /* Convergence Group PSN Assured */
            isInNet(hostIP, '137.221.176.0', '255.255.248.0')) {
            return 'DIRECT';
        }

        /* Go direct over legacy government networks */
        if (
            /* HSCIC N3   */
            isInNet(hostIP, '20.146.120.128', '255.255.255.128') ||
            /* HSCIC N3   */
            isInNet(hostIP, '20.146.248.128', '255.255.255.128') ||
            /* legacy GCSX   */
            isInNet(hostIP, '51.62.0.0', '255.255.192.0') ||
            /* legacy GSI, GSE, GSX, */
            isInNet(hostIP, '51.63.0.0', '255.255.0.0') ||
            /* legacy PNN SCN  */
            isInNet(hostIP, '51.64.0.0', '255.255.0.0') ||
            /* legacy PNN CJX  */
            isInNet(hostIP, '51.65.224.0', '255.255.224.0') ||
            /* legacy PNN CJX  */
            isInNet(hostIP, '51.67.224.0', '255.255.224.0') ||
            /* legacy PNN SCN  */
            isInNet(hostIP, '62.208.251.0', '255.255.255.0') ||
            /* HSCIC N3   */
            isInNet(hostIP, '155.231.0.0', '255.255.0.0') ||
            /* HSCIC N3   */
            isInNet(hostIP, '194.189.100.144', '255.255.255.240') ||
            /* HSCIC N3   */
            isInNet(hostIP, '194.189.111.96', '255.255.255.224') ||
            /* HSCIC N3   */
            isInNet(hostIP, '194.189.111.224', '255.255.255.224') ||
            /* HSCIC N3   */
            isInNet(hostIP, '194.189.113.128', '255.255.255.224')) {
            return 'DIRECT';
        }

        /* Don't proxy local addresses.*/
        if (false) {
            return 'DIRECT';
        } else
            return 'PROXY proxy.example.com:8123';
    }
}
