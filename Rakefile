desc 'Build rubydata/discourse image'
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
end

namespace :build do
  namespace :backends do
    task up: 'compose:up:detached:postgres'
    task up: 'compose:up:detached:redis'
    task down: 'compose:down'
  end
end

namespace :compose do
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

    task detached: 'compose:up:detached:backends' do
      sh 'docker-compose', 'run', 'discourse', 'su', 'discourse', '-c', 'cd /var/www/discourse && bundle exec rake db:migrate'
      sh 'docker-compose', 'up', '-d', 'discourse'
    end
  end

  task up: 'compose:up:detached:backends' do
    sh 'docker-compose', 'run', 'discourse', 'su', 'discourse', '-c', 'cd /var/www/discourse && bundle exec rake db:migrate'
    sh 'docker-compose', 'up'
  end

  task :down do
    sh 'docker-compose', 'down'
  end
end
