desc 'Build rubydata/discourse image'
task build: 'prepare:environment'
task :build do
  begin
    Rake::Task['build:backends:up'].invoke
    sh 'docker-compose', 'build'
  ensure
    Rake::Task['build:backends:down'].invoke
  end
end

desc 'Push rubydata/discourse image'
task :push do
  sh 'docker', 'push', 'rubydata/discourse'
  hash = `git rev-parse HEAD`.chomp
  sh 'docker', 'push', "rubydata/discourse:#{hash}"
end

namespace :prepare do
  task environment: :check
  task :environment do
    ENV['DISCOURSE_SMTP_USER_NAME'] = ENV['AWS_ACCESS_KEY_ID']
    ENV['DISCOURSE_SMTP_PASSWORD']  = ses_smtp_password
  end

  task :check do
    unless ENV['AWS_ACCESS_KEY_ID']
      raise 'AWS_ACCESS_KEY_ID is required'
    end
    unless ENV['AWS_SECRET_ACCESS_KEY']
      raise 'AWS_ACCESS_KEY_ID is required'
    end
  end
end

namespace :build do
  namespace :backends do
    task up: 'compose:up:detached:postgres'
    task up: 'compose:up:detached:redis'
    task down: 'compose:down'
  end
end

namespace :compose do
  namespace :run do
    task 'discourse:db:migrate' => 'compose:up:detached:backends'
    task 'discourse:db:migrate' do
      sh 'docker-compose', 'run', 'discourse',
         'su', 'discourse', '-c', 'cd /var/www/discourse && bundle exec rake db:migrate'
    end
  end

  namespace :up do
    namespace :detached do
      task :postgres do
        sh 'docker-compose', 'up', '-d', 'postgres'
      end

      task :redis do
        sh 'docker-compose', 'up', '-d', 'redis'
      end

      task backends: :postgres
      task backends: :redis
    end

    task detached: 'prepare:environment'
    task detached: 'compose:run:discourse:db:migrate'
    task :detached do
      sh 'docker-compose', 'up', '-d', 'discourse'
    end
  end

  task up: 'prepare:environment'
  task up: 'compose:run:discourse:db:migrate'
  task :up do
    sh 'docker-compose', 'up'
  end

  task :down do
    sh 'docker-compose', 'down'
  end
end

def ses_smtp_password
  require 'openssl'
  require 'base64'
  key = ENV['AWS_SECRET_ACCESS_KEY']
  message = 'SendRawEmail'
  signature = OpenSSL::HMAC.digest('sha256', key, message)
  versioned_signature = "\x02#{signature}"
  password = Base64.strict_encode64(versioned_signature)
  return password
end
