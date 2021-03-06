ENV["RAILS_ENV"] ||= "test"
ENV["ELASTIC_SEARCH_PORT"] ||= "9200"
ENV["ELASTIC_SEARCH_URL"] ||= "http://localhost:#{ENV["ELASTIC_SEARCH_PORT"]}/"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

require "byebug"
require "simplecov"
require "webmock"
require "webmock/rspec"
require "capybara/rails"
require "elasticsearch/extensions/test/cluster"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/spec_helpers/*.rb")].each { |f| require f }
SimpleCov.start

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.mock_with :mocha

  config.include FactoryBot::Syntax::Methods

  # Configure ElasticSearch

  # Allow ElasticSearch on port 9250 (configured for test)
  WebMock.disable_net_connect!(allow: "localhost:#{ENV["ELASTIC_SEARCH_PORT"]}")

  # Create indexes for all elastic searchable models
  config.before :each, %w[feature model].include?(:type) do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.create_index!
          model.__elasticsearch__.refresh_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          # This kills "Index does not exist" errors being written to console
          # by this: https://github.com/elastic/elasticsearch-rails/blob/738c63efacc167b6e8faae3b01a1a0135cfc8bbb/elasticsearch-model/lib/elasticsearch/model/indexing.rb#L268
        rescue => e
          warn "There was an error creating the elasticsearch index for #{model.name}: #{e.inspect}"
        end
      end
    end
  end

  # Delete indexes for all elastic searchable models to ensure clean state between tests
  config.after :suite do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          # This kills "Index does not exist" errors being written to console
          # by this: https://github.com/elastic/elasticsearch-rails/blob/738c63efacc167b6e8faae3b01a1a0135cfc8bbb/elasticsearch-model/lib/elasticsearch/model/indexing.rb#L268
        rescue => e
          warn "There was an error removing the elasticsearch index for #{model.name}: #{e.inspect}"
        end
      end
    end
  end
end
