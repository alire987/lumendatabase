ENV['RAILS_ENV'] ||= 'test'

# Prevent things in config/environment from being reloaded if they have
# already been loaded in a previous test. HTTP_ERRORS is chosen at
# random from things initialized in that directory.
unless defined? HTTP_ERRORS
  require File.expand_path('../config/environment', __dir__)
end

# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'rubygems'
require 'rspec/rails'
require 'capybara/poltergeist'
require 'capybara/rspec'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# https://docs.travis-ci.com/user/common-build-problems/#capybara-im-getting-errors-about-elements-not-being-found
Capybara.default_max_wait_time = 15

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    port: 51674 + ENV['TEST_ENV_NUMBER'].to_i,
    phantomjs_logger: File.open("#{Rails.root}/log/test_phantomjs.log", 'a')
  )
end

Capybara.javascript_driver = :poltergeist
Capybara.server = :webrick

Capybara.configure do |config|
  config.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Enables --only-failures.
  config.example_status_persistence_file_path = 'rspec_examples.txt'

  #config.raise_errors_for_deprecations!
end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # with.test_framework :minitest
    # with.test_framework :minitest_4
    # with.test_framework :test_unit

    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
    # Or, choose the following (which implies all of the above):
    # with.library :rails
  end
end
