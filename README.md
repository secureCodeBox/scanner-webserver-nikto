---
title: "Nikto"
path: "scanner/Nikto"
category: "scanner"
usecase: "Webserver Vulnerability Scanner"
release: "https://img.shields.io/github/release/secureCodeBox/scanner-webserver-nikto.svg"

---

![nikto logo](https://cirt.net/files/alienlogo_3.gif)

Nikto is a free software command-line vulnerability scanner that scans webservers for dangerous files/CGIs, outdated server software and other problems. It performs generic and server type specific checks. It also captures and prints any cookies received. 

<!-- end -->

# About

This repository contains a self contained µService utilizing the Nikto scanner for the secureCodeBox project. To learn more about the Nikto scanner itself visit [cirt.net] or [Nikto GitHub].

## Nikto parameters

To hand over supported parameters through api usage, you can set following attributes:

```json
[
  {
    "name": "nikto",
    "context": "some Context",
    "target": {
      "name": "targetName",
      "location": "http://your-target.com/",
      "attributes": {
	  	"NIKTO_PORTS": "[int port]",
		"NIKTO_PARAMETER": "[String parameter]" "//See official Nikto documentation" 
      }
    }
  }
]
```

## Example

Example configuration:

```json
[
  {
    "name": "nikto",
    "context": "Example Test",
    "target": {
      "name": "BodgeIT on OpenShift",
      "location": "bodgeit-scb.cloudapps.iterashift.com",
      "attributes": {
	  	"NIKTO_PORTS": "80",
		"NIKTO_PARAMETER": ""
		}
    }
  }
]
```

Example Output:

```json
{
    "findings": 
	[
	  {
		"id": "3412b590-ceaa-47a7-b8d6-76a9d988b562",
		"name": "The anti-clickjacking X-Frame-Options header is not present.",
		"osi_layer": "APPLICATION",
		"severity": "INFORMATIONAL",
		"reference": {
		  "id": "OSVDB-0",
		  "source": "OSVDB-0"
		},
		"attributes": {
		  "http_method": "GET",
		  "hostname": "bodgeit-scb.cloudapps.iterashift.com",
		  "path": "/",
		  "ip_address": "52.58.225.89",
		  "port": 80
		},
		"location": "bodgeit-scb.cloudapps.iterashift.com:80/",
		"false_positive": false
	  },
	  {
		"id": "afab5c05-2bf3-4032-9b13-87b5978a0d34",
		"name": "The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS",
		"osi_layer": "APPLICATION",
		"severity": "INFORMATIONAL",
		"reference": {
		  "id": "OSVDB-0",
		  "source": "OSVDB-0"
		},
		"attributes": {
		  "http_method": "GET",
		  "hostname": "bodgeit-scb.cloudapps.iterashift.com",
		  "path": "/",
		  "ip_address": "52.58.225.89",
		  "port": 80
		},
		"location": "bodgeit-scb.cloudapps.iterashift.com:80/",
		"false_positive": false
	  },
	  {
		"id": "456dd677-e777-4ec3-973d-a26bfa257a97",
		"name": "The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type",
		"osi_layer": "APPLICATION",
		"severity": "INFORMATIONAL",
		"reference": {
		  "id": "OSVDB-0",
		  "source": "OSVDB-0"
		},
		"attributes": {
		  "http_method": "GET",
		  "hostname": "bodgeit-scb.cloudapps.iterashift.com",
		  "path": "/",
		  "ip_address": "52.58.225.89",
		  "port": 80
		},
		"location": "bodgeit-scb.cloudapps.iterashift.com:80/",
		"false_positive": false
	  }
	]
}
```

## Development

### Configuration Options

To configure this service specify the following environment variables:

| Environment Variable       | Value Example |
| -------------------------- | ------------- |
| ENGINE_ADDRESS             | http://engine |
| ENGINE_BASIC_AUTH_USER     | username      |
| ENGINE_BASIC_AUTH_PASSWORD | 123456        |

### Local setup

1. Clone the repository
2. You might need to install some dependencies `gem install sinatra rest-client`
3. Run locally `ruby src/main.rb`

### Test

To run the testsuite run:

`rake test`

### Build

To build the docker container run:

`docker build -t CONTAINER_NAME .`


[![Build Status](https://travis-ci.com/secureCodeBox/scanner-webserver-nikto.svg?branch=master)](https://travis-ci.com/secureCodeBox/scanner-webserver-nikto)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub release](https://img.shields.io/github/release/secureCodeBox/scanner-webserver-nikto.svg)](https://github.com/secureCodeBox/scanner-webserver-nikto/releases/latest)


[cirt.net]: https://cirt.net/
[Nikto GitHub]: https://github.com/sullo/nikto
