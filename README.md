# HTTP Lab 1 - Virtual Hosts

This document explains how I configured two Apache Virtual Hosts (`apolo.olimpo.test` and `atenea.olimpo.test`) on a single web server using a local DNS server and Vagrant.

## 1. Initial Configuration and Environment Setup

To start this practice, I used Vagrant to create two Debian virtual machines on a private network (`192.168.57.0/24`). The first machine acts as the DNS server (`ns1.olimpo.test` with IP `192.168.57.10`), and the second is the Apache web server (`mercurio.olimpo.test` with IP `192.168.57.11`).

I started the environment by opening my terminal and running the `vagrant up` command. Once the machines were running, I needed to check if the basic DNS resolution was working. I used the `dig` command on both machines to see if they could translate their own names into the correct IP addresses.

DNS verification from dns(<img/01-dig-apolo.png>)


## 2. Apolo DNS Configuration

To make the first website work, I had to create an alias. I edited the `olimpo.test` forward zone file and added a CNAME record so that the name `apolo` points directly to the web server (`mercurio.olimpo.test.`).

Before saving and applying this, it is very important to check for syntax errors. I used the command `sudo named-checkzone olimpo.test /vagrant/files/ns1.olimpo.test/olimpo.test.dns`. It returned an "OK" message.

Apolo zone validation(<img/03-apolo-olimpo.test.png>)

After applying the changes with `vagrant provision dns`, I tested the new alias. To be completely sure it worked without shortcuts, I ran the full `dig apolo.olimpo.test` command. Because this command generates a lot of text, I looked carefully at the "ANSWER SECTION" in the terminal output. There, I could clearly confirm that `apolo` was pointing to `mercurio.olimpo.test.` and resolving to the `192.168.57.11` IP address.

## 3. Apolo Web Server Deployment

Next, I configured the Apache VirtualHost for Apolo. I set the `ServerName` to `apolo.olimpo.test` and defined its document root folder. The most important security setting here is `Options +Indexes`. I also configured custom 403 and 404 error pages and separate log files. After enabling the site with `sudo a2ensite apolo.olimpo.test.conf`, I restarted the Apache service.

To verify that it worked, I opened my web browser:

First, I visited the root address (`http://apolo.olimpo.test`). Because I enabled `Options +Indexes` and I did not put a default `index.html` file in the folder, the server showed a list of all the files inside the directory.
Apolo directory listing(<img/05-index.html.png>)

Then, I visited `http://apolo.olimpo.test/apolo.html`, and the normal HTML page loaded successfully.
Apolo site(<img/04-apolo.html.png>)

Finally, I tried to access a file that does not exist (`http://apolo.olimpo.test/index.html`). The server correctly returned my custom error page saying "Resource not found on apolo.olimpo.test".
Apolo 404 error(<img/06-404.html.png>)

## 4. Atenea DNS Configuration

I repeated the DNS process for the second website. I added another CNAME record for `atenea` pointing to `mercurio.olimpo.test.`. Because I modified the zone file, I had to increase the serial number to `3` so the DNS service knows there is a new version and updates it.

I checked the syntax again and ran the provision command. To verify the connection, I ran `dig atenea.olimpo.test` and checked the "ANSWER SECTION" again. Everything was correct, and the domain successfully pointed to the web server's IP.

## 5. Atenea Web Server Deployment

The Atenea VirtualHost has a stricter security configuration. I set the `ServerName` and the document root, but this time I used the `Options -Indexes` directive. This tells Apache to completely block directory listing.

I enabled the site, restarted Apache, and tested the URLs in the browser:

When I accessed the specific HTML file (`http://atenea.olimpo.test/atenea.html`), the page displayed perfectly.
Atenea site(<img/07-atenea.html.png>)

However, when I tried to visit the root domain (`http://atenea.olimpo.test`) without specifying a file, the server blocked me. It returned a custom 403 error saying "You do not have permission to access atenea.olimpo.test".
Atenea 403 error(<img/08-atenea.olimpo.test.png>)

When I asked for a missing file (`http://atenea.olimpo.test/index.html`), I got my custom 404 error page.
Atenea 404 error(<img/09-index.htmlatenea.png>)

I also tried to access the `messages/` subfolder directly (`http://atenea.olimpo.test/messages/`). Since directory listing is disabled, this also returned a 403 Forbidden error.
Atenea messages 403 error(<img/10-atena-messages.png>)

## 6. Comparing the Security Directives

The main difference between Apolo and Atenea is how they handle directory requests. 

Apolo uses `Options +Indexes`. This means if a user visits a folder that does not have a default HTML index file, the server will openly show a list of all the files inside that folder (returning a 200 OK status).

Atenea uses `Options -Indexes`. This is much more secure because it completely forbids directory browsing. If a user tries to access a folder without requesting a specific file, the server will reject the connection and return a 403 Forbidden status to protect the internal files.

## 7. Script Automation

After testing everything manually, I decided to automate the Apache configuration. I added all the necessary commands to my `apache2-provision.sh` script.

When Vagrant runs this script, it automatically copies the configuration files to `/etc/apache2/sites-available/`, enables the Apolo and Atenea sites using `a2ensite`, checks the Apache syntax, and restarts the service. I tested this by running `vagrant provision web` in my terminal, and it completed the entire process without any manual intervention.

## 8. Final Reproducibility Test

As a system administrator, it is important to prove that the infrastructure is solid and reproducible as code. To test this, I completely destroyed both virtual machines by running `vagrant destroy `. This deleted all the memory and hard drives.

Then, I rebuilt the entire laboratory from scratch using the `vagrant up` command. Because everything was automated in the Vagrantfile and the provisioning scripts, the network, the DNS zones, the aliases, and the Apache Virtual Hosts were created automatically. I ran the `dig` commands and checked the browser again, and everything worked perfectly on the first try.
