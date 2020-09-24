# Southwest Checkin

Automatically check in to Southwest flights using this easy-to-use gem. It'll also email you the results so you know ASAP whether a check in was successful. Seconds count when you're fighting for that window or aisle seat!

## Installation

    gem install autoluv

## Usage

### Schedule a Check In

    # both departing and returning flights (if applicable) are scheduled.
    autoluv schedule ABCDEF John Doe

    # wrap names in double quotes if they have spaces
    autoluv schedule ABCDEF "John Doe" Smith

### Schedule a Check In With Email Notification

Make sure you follow the instructions below for configuring email notifications.

    autoluv schedule ABCDEF John Doe john.doe@helloworld.com

    # you can optionally specify a second email address as well. useful if you
    # schedule flights for friends but also want to be notified of the results.
    # NOTE: put your email address in the first field and your friend's in the second.
    autoluv schedule ABCDEF John Doe your.email@helloworld.com john.doe@helloworld.com

### Check In Immediately

    autoluv checkin ABCDEF Jane Doe

## Configure Email Notifications

This is optional, however, highly recommended. Especially if a scheduled check in fails, you'll get notified and can manually check in. Every second counts!

On a successful check in, the email will share boarding positions for each passenger.

### Step 1

Create the file `.autoluv.env` in your user's home directory.

    cd ~
    nano .autoluv.env

### Step 2

Copy/paste the following in the text editor.

```
LUV_FROM_EMAIL  = sendfrom@thisemail.com
LUV_USER_NAME   = loginfrom@thisemail.com
LUV_PASSWORD    = supersecurepassword
LUV_SMTP_SERVER = smtp.emailserver.com
LUV_PORT        = 587
```

### Step 3

Replace the values with the appropriate SMTP settings for your email provider and save the file (`Ctrl+O` to save, `Ctrl+X` to exit the editor).

`LUV_FROM_EMAIL` should be the email address associated with `LUV_USER_NAME`.

**Note**: If your email account has two-factor authentication enabled, be sure to use an app-specific password above (and *not* your account password).

### Get Text Instead of Email Notifications

[Use this Zap](https://zapier.com/apps/email/integrations/sms/9241/get-sms-alerts-for-new-email-messages) to get a custom Zapier email address that forwards emails as text messages. It's handy for people like me who don't have email notifications enabled on their phone or computer and want check-in results ASAP.

### Delete a Scheduled Check In

`autoluv` uses the `at` command behind the scenes to check in at a specific time. Use the related `atq` and `atrm` commands to view scheduled check-ins and delete them.

    # view scheduled check ins (make note of the first column's number)
    atq
    11	Tue Sep 22 08:05:00 2020 a user
    12	Mon Sep 28 15:45:00 2020 a user
    7	Wed Sep 23 11:40:00 2020 a user

    # cancel a check in
    atrm 11

    # view details about a check in. the last line in the output will show you the confirmation number and name.
    at -c 11

## Update Gem

    gem update autoluv --conservative

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
