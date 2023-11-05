# harakahog
Mailhog behind Haraka for STARTTLS

## Problem statement
For QA purposes there is a need for a mailcatcher service that supports TLS. [MailHog](https://github.com/mailhog/MailHog) doesn't.

## Solution
Let's run MailHog behind proper MTA that knows how to support STARTTLS properly.
Let's make haraka to:
- use tls
- accept inbound connections only from a whitelist of IP addresses
- use SMTP plain auth only over TLS
- proxy all received emails to buddy MailHog container on the same compose

Let's use `docker compose` for this PoC (but helm chart would be a good thing as well).

