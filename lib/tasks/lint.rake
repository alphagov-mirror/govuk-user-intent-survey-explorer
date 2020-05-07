# frozen_string_literal: true

desc "lint Ruby, FactoryBot, Sass and Javascript"
task lint: :environment do
  sh "bundle exec rubocop --format clang"
  sh "bundle exec rake factorybot:lint RAILS_ENV='test'"
end

namespace :factorybot do
  desc "Run FactoryBot linter"
  task lint: :environment do
    if Rails.env.test?
      ActiveRecord::Base.transaction do
        FactoryBot.lint(traits: true)
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factorybot:lint RAILS_ENV='test'")
      fail if $exitstatus.nonzero?
    end
  end
end
