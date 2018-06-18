require 'unione/client'
module Unione
  class Sender

    attr_reader :settings

    def initialize(args)
      @settings = { api_key: nil, username: nil }

      @logger = Rails.logger
      @logger.info "UNIONE:INIT"

      args.each do |arg_name, arg_value|
        @settings[arg_name.to_sym] = arg_value
      end

      @client = Unione::Client.new(@settings[:api_key], @settings[:username])
    end

    def deliver!(mail)
      recipients = []
      mail_to    = [*mail.to]

      @logger.info "--- UNIONE: deliver! method ---"
      @logger.info "--- UNIONE: mail_to = #{mail_to.inspect} ---"

      return if mail_to.blank?

      mail_to.each do |email_address|
        recipients << {email: email_address}
      end

      send_params = {
        message: {
          subject: mail.subject,
          from_email: mail.from.first,
          from_name: @settings[:sender_name] || mail.from.split('@').first,
          recipients: recipients,
          body: { html: mail.body.raw_source }
        }
      }
      @logger.info "--- UNIONE: send emails ---"

      result = @client.send_emails(send_params)

      @logger.info "--- UNIONE: response = #{result.inspect} ---"
      result
    end
  end
end
