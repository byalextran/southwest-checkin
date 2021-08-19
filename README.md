As of August 2021, Southwest made a change to their API that broke this (and similar) check-in apps. I'm looking into a fix but no guarantees on a timeline since I've got higher priority things I need to work on right now. 

# Southwest Checkin

Automatically check in to Southwest flights using this easy-to-use gem. It'll also email you the results so you know ASAP whether a check in was successful. Seconds count when you're fighting for that window or aisle seat!

## Requirements

* A *nix-based server that will be on when you need to check in
* Ruby 2.3 or higher
* The `at` command

Tested and working on an Ubuntu 20.04 server (hosted by DigitalOcean).

## Installation

    gem install autoluv

## Usage

### Schedule a Check-In

    autoluv schedule ABCDEF John Doe

Both departing and returning flights (if applicable) will be scheduled for all passengers tied to the confirmation number. After scheduling, there's no need to keep the terminal window open or active. The check in will happen behind the scenes at the appropriate time.

**Note:** If a first or last name includes a space, wrap it in double quotes (e.g. "Mary Kate")

### Schedule a Check-In With Email Notification

Before using this command, follow the instructions below to configure the required settings.

    autoluv schedule ABCDEF John Doe john.doe@email.com optional@bcc.com

The second email address is optional and will be BCCed the results.

### Check In Immediately

    autoluv checkin ABCDEF John Doe

## Configure Email Notifications

This is optional, however, highly recommended. Especially if a scheduled check-in fails, you'll get notified and can manually check in. Every second counts!

Boarding positions are shown for each passenger when a check-in succeeds.

**Step 1:** Create the file `.autoluv.env` in your user's home directory.

    nano ~/.autoluv.env

**Step 2:** Copy/paste the following into the text editor.

```
LUV_FROM_EMAIL  = from@email.com
LUV_USER_NAME   = from@email.com
LUV_PASSWORD    = supersecurepassword
LUV_SMTP_SERVER = smtp.email.com
LUV_PORT        = 587
```

**Step 3:** Replace the values with the appropriate SMTP settings for your email provider. `LUV_FROM_EMAIL` should be the email address associated with `LUV_USER_NAME`.

If your email account has two-factor authentication enabled, be sure to use an app-specific password and *not* your account password.

**Step 4:** Hit `Ctrl+O` to save the file and then `Ctrl+X` to exit the text editor.

### Test Email Notifications

To verify your SMTP settings, schedule a check-in with invalid information and a valid email address.

    autoluv schedule AAAAAA Fake Name valid@email.com

If everything is set up correctly, you'll get an email notifying you of an unsuccessful check-in. 

### Get Text Instead of Email Notifications

[Use this Zap](https://zapier.com/apps/email/integrations/sms/9241/get-sms-alerts-for-new-email-messages) to get a custom Zapier email address that forwards emails as text messages. It's handy for people like me who don't have email notifications enabled on their phone or computer and want check-in results ASAP.

## Manage Check-Ins

`autoluv` uses the `at` command behind the scenes to check in at a specific time. Use the related `atq` and `atrm` commands to manage check-ins.

### View Scheduled Check-Ins
Make note of the first column's number.

    atq
    11	Tue Sep 22 08:05:00 2020 a user
    12	Mon Sep 28 15:45:00 2020 a user
    7	Wed Sep 23 11:40:00 2020 a user

### Cancel a Check-In

    atrm 11

### View Check-In Details
The last line in the output will show you the confirmation number and name.

    at -c 11

## Update Gem

    gem update autoluv --conservative

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
