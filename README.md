# About scanner-webserver-nikto

scanner-webserver-nikto is a self contained µService utilizing the Nikto Webserverscanner for the SecureCodeBox.

## Configuration Options

To configure this service specify the following environment variables:

| Environment Variable       | Value Example         |
| -------------------------- | --------------------- |
| ENGINE_ADDRESS             | http://securebox/rest |
| ENGINE_BASIC_AUTH_USER     | username              |
| ENGINE_BASIC_AUTH_PASSWORD | 123456                |

## Development

### Local setup

1.  Clone the repository
2.  You might need to install some dependencies `gem install sinatra rest-client`
3.  Run locally `ruby src/main.rb`

### Test

To run the testsuite run:

`rake test`

### Build

To build the docker container run:

`docker build -t CONTAINER_NAME .`
