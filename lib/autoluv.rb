require "autoluv/version"
require "autoluv/southwestclient"
require "pony"

require "dotenv"
Dotenv.load("#{Dir.home}/.autoluv.env")

module Autoluv
  class Error < StandardError; end

  PONY_OPTIONS = {
    from: "#{ENV["LUV_FROM_EMAIL"]}",
    via: :smtp,
    via_options: {
      address: "#{ENV["LUV_SMTP_SERVER"]}",
      port: "#{ENV["LUV_PORT"]}",
      user_name: "#{ENV["LUV_USER_NAME"]}",
      password: "#{ENV["LUV_PASSWORD"]}",
      authentication: :login,
    },
  }

  LOG_DIR = File.expand_path("../logs/", __dir__)

  def self.log(confirmation_number, first_name, last_name, message, exception)
    log_path = "#{LOG_DIR}/#{first_name} #{last_name}"
    FileUtils.mkdir_p(log_path) unless Dir.exist?(log_path)

    logger = Logger.new("#{log_path}/#{confirmation_number}.log")

    logger.error(message + "\n" + exception.backtrace.join("\n"))
  end

  def self.notify_user(success, confirmation_number, first_name, last_name, data = {})
    subject = "#{first_name} #{last_name} (#{confirmation_number}): "
    body = ""

    if success
      subject << "Succeeded at #{data[:metadata][:end_time]}. #{data[:metadata][:attempts]} attempt(s) in #{data[:metadata][:elapsed_time]} sec."
      body = data[:boarding_positions]
    else
      subject << "Unsuccessful check-in."
      body = data[:exception_message]
      Autoluv::log(confirmation_number, first_name, last_name, body, data[:exception])
    end

    if data[:to].nil?
      puts body
    else
      Autoluv::email(subject, body, data[:to], data[:bcc])
    end
  end

  def self.email(subject, body, to, bcc = nil)
    # only send an email if we have all the environmental variables set
    return if PONY_OPTIONS.values.any? &:empty?

    Pony.mail(PONY_OPTIONS.merge({
      to: to,
      bcc: bcc,
      subject: subject,
      body: body,
    }))
  end
end
