require 'mail'
require 'erb'

module Tasks
  module TaskHelper
    extend self

    def send_mail(aliases, template, subject, params, as_html=false)
      template_erb = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates/#{template}.erb")))
      body_content = template_erb.result(Binding.new(params).get_binding)
      mail_server = Rails.configuration.mail_server
      Mail.deliver do
        delivery_method mail_server[:type], :address => mail_server[:host], :port => mail_server[:port]
        from     Rails.configuration.notify_from_alias
        to       aliases
        subject  subject
        if as_html
          html_part do
            content_type "text/html; charset=UTF-8"
            body body_content
          end
        else
          text_part do
            content_type "text/plain; charset=UTF-8"
            body body_content
          end
        end
      end
      true
    end

    def find_new_post_notified_users
      # TODO may need cache
      users = User.find(:all)
      notified_users = []
      users.each do |user|
        if user.notification
          notify = JSON.parse(user.notification)
          if notify.fetch('new_post', true)
            notified_users << user
          end
        else
          notified_users << user
        end
      end
      notified_users
    end

    private

    class Binding
      def initialize(params)       
        @params = params
        @portal_root = Rails.configuration.portal_root
      end

      def get_binding
        binding()
      end
    end

  end
end
