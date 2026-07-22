Apache HTTP Status Codes Configuration and Testing
This repository documents the technical implementation and testing of various HTTP status codes (200, 301, 401, 503) using an Apache/2.4.64 (Ubuntu) server environment. The project focuses on server-side configuration via VirtualHost directives and the use of the Rewrite engine.

Environment and Tools
Server: Apache/2.4.64

Operating System: Ubuntu

Tools used: curl, apache2-utils, systemctl

Modules required: auth_basic, rewrite

1. Success Status (200 OK)
After the initial installation of Apache, the server's availability was verified by performing a request to the localhost.

Bash
curl -i localhost
The response confirmed a status code of 200 OK, indicating the server successfully processed the request and served the default index page.

2. Authentication and Unauthorized Status (401 Unauthorized)
To simulate restricted access, HTTP Basic Authentication was implemented.

Setup Steps:

Install Apache utilities:

Bash
sudo apt update
sudo apt install apache2-utils
Create the password file and user:

Bash
sudo htpasswd -c /etc/apache2/.htpasswd giulia
Modify the VirtualHost configuration in /etc/apache2/sites-available/000-default.conf:

Apache
<Directory "/var/www/html">
    AuthType Basic
    AuthName "Restricted Content"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
Restart the service:

Bash
sudo systemctl restart apache2
Verification via curl without credentials results in a 401 Unauthorized error.

3. Redirection (302 Found)
To test temporary redirection, the Redirect directive was utilized to point requests from the index page to a new destination.

Configuration:

Apache
RewriteEngine On
Redirect /index.html http://newpage.html
The server response verifies the redirection with a 302 Found status and the updated Location header.

4. Service Unavailable (503 Service Unavailable)
A 503 status was simulated by forcing a maintenance state through rewrite rules. This configuration redirects all traffic to a specific error page while returning the correct status code to the client.

Configuration in 000-default.conf:

Apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !503\.html
RewriteRule ^.*$ /errors/503.html [R=503,L]
The RewriteCond ensures that the error page itself is excluded from the redirection to prevent an infinite loop.

Verification:

Bash
curl -i localhost
The output confirms HTTP/1.1 503 Service Unavailable, displaying the content of the maintenance page.

Summary of Configuration Directives
Status Code	Implementation Method
200 OK	Standard DocumentRoot serving
401	AuthType Basic + AuthUserFile
302	Redirect directive
503	RewriteRule with [R=503,L]
