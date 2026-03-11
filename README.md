# harakahog
MailHog behind Haraka for STARTTLS

## Problem statement
For QA purposes there is a need for a mailcatcher service that supports TLS. [MailHog](https://github.com/mailhog/MailHog) doesn't.

## Solution
Let us configure Haraka to operate behind a proper MTA that is capable of supporting STARTTLS in a secure manner.
Specifically, we will configure Haraka to:
- utilize TLS encryption
- only accept inbound relay connections from a pre-approved whitelist of IP addresses
- use SMTP LOGIN auth solely over TLS
- forward all received emails to the companion MailHog container.

## Prerequisites

## Docker installation

### To configure
I'm proposing an approach that combines two types of relay authorization: IP ACL and SMTP user LOGIN type authZ.

Also, system will need some key and certificate.

#### Prepare key and certificate

Run 

```sh
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

```sh
brew install swaks
```

And then let's send some test email
```sh
swaks --from admin@example.org --to test@abc.com --server localhost:587 -tls -a LOGIN
```

`-tls` option forces STARTTLS communucation. `-a LOGIN` forces LOGIN SMTP auth.

Remember that haraka proxy is configured to allow relays from given whitelisted IP or after successful auth.

See the mailhog web ui (http://localhost:8025) to see received emails.

## Helm installation

A Helm chart for harakahog is available in the GHCR (GitHub Container Registry).

### Prerequisites

- Kubernetes cluster
- Helm 4.x

### Install

#### 1. Create secret with your TLS key and cert.

If you don't have TLS key and cert, you can generate self-signed for testing purposes:

```sh
openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout tls_key.pem -outform PEM -x509 -days 365 -out tls_cert.pem
```

Then create a secret:

```sh
kubectl create secret generic harakahog-haraka-tls \
  --from-file=tls_key.pem=tls_key.pem \
  --from-file=tls_cert.pem=tls_cert.pem
```

#### 2. Login to GHCR (one time)

```sh
helm registry login ghcr.io
```

#### 3. Install the chart

Check for the latest chart version in [GHCR](https://github.com/users/kopernic-pl/packages/container/harakahog).

```sh
helm install harakahog oci://ghcr.io/kopernic-pl/charts/harakahog \
  --version <latest-version>
```

### Access services and test

By default, services are accessible within the cluster. You can port-forward to your local machine using:

```sh
kubectl port-forward svc/harakahog-haraka 5870:5870
kubectl port-forward svc/harakahog-mailhog 8025:8025
```

And access MailHog web UI at http://localhost:8025.

You can verify mail forward by sending a dummy email to Haraka using `swaks`:

```sh
swaks --from admin@example.org --to test@abc.com --server localhost:5870 -tls -a LOGIN
```

Default SMTP credentials are `admin@example.org`/`admin123`.

### Customization

To tune chart, you can override default values from [values.yaml](https://github.com/kopernic-pl/harakahog/blob/main/charts/harakahog/values.yaml).
For more information check values documentation in [README.md](https://github.com/kopernic-pl/harakahog/blob/main/charts/harakahog/README.md).

### Helm dev

Before pushing any changes of the chart, make sure to run `helm unittest charts/harakahog -u` locally to verify 
if all helm tests are passing and to update test snapshots.
