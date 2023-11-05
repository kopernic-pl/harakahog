# harakahog
Mailhog behind Haraka for STARTTLS

## Problem statement
For QA purposes there is a need for a mailcatcher service that supports TLS. [MailHog](https://github.com/mailhog/MailHog) doesn't.

## Solution
Let us configure Haraka to operate behind a proper MTA that is capable of supporting STARTTLS in a secure manner.
Specifically, we will configure Haraka to:
- utilize TLS encryption
- only accept inbound relay connections from a pre-approved whitelist of IP addresses
- use SMTP LOGIN auth solely over TLS
- forward all received emails to the companion MailHog container within the same Docker Compose environment.

For this proof-of-concept, we will be using Docker Compose, although a Helm chart would also be a viable option.

### To configure
I'm proposing an approach that combines two types of relay authorization: IP ACL and SMTP user LOGIN type authZ.

Also, system will need some key and certificate.

#### Prepare key and certificate

Run 

```bash
openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout tls_key.pem -outform PEM -x509 -days 365 -out tls_cert.pem
```
and answer certificate questions. Make sure that generated files are in `h-config` dir and `h-config\tls.ini` file is pointing at them.

For commercial, non-self-signed certificate, one needs to construct a [certificate chain file](https://github.com/haraka/Haraka/wiki/Setting-up-TLS-with-CA-certificates).

#### Prepare user credentials
Edit `h-config/auth_flat_file.ini` and add some user with password there.

#### Configure IP address ACL
If you want to enable IP address controller relay, add IP/range in CIDR notation to `h-config/relay_acl_allow`. One entry per line.

As an example - values for localhost and for MacOS docker internal network are already there.

### To run

`docker compose up`

When run, there will be some files created in `h-config`, most notably `dhparams.pem` file and `me` server identity file.

### To test
SMTP over telnet is not *that* complicated but let's use `swaks` (https://github.com/jetmore/swaks) on MacOS.

```bash
brew install swaks
```

And then let's send some test email
```bash
swaks --from asd@xyz.co --to x@asdffdsa.com --server localhost:587 -tls -a LOGIN
```

`-tls` option forces STARTTLS communucation. `-a LOGIN` forces LOGIN SMTP auth.

Remember that haraka proxy is configured to allow relays from given whitelisted IP or after successful auth.

See the mailhog web ui (http://localhost:8025) to see received emails.
