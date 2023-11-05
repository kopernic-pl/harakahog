# harakahog
Mailhog behind Haraka for STARTTLS

## Problem statement
For QA purposes there is a need for a mailcatcher service that supports TLS. [MailHog](https://github.com/mailhog/MailHog) doesn't.

## Solution
Let's run MailHog behind proper MTA that knows how to support STARTTLS properly and will
