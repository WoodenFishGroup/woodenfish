Wf::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.els.hulu.com',
      port:                 25
  }
  config.notify_from_alias = "woodenfish-staging@hulu.com"
  config.portal_root = "http://woodenfish.staging.hulu.com/"
  config.portal_host = "woodenfish.staging.hulu.com"
  config.ga_id = "UA-48995483-2"
end

redis = Redis.new(
  :host => "elsaplogbroker01.server.hulu.com", :port =>6379, :thread_safe => true)
Resque.redis = Redis::Namespace.new(:wf_staging, :redis => redis)
