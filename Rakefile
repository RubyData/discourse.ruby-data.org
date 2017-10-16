desc 'Build rubydata/discourse image'
task :build do
  begin
    Rake::Task['build:postgres:up'].invoke
    sh 'docker-compose', 'build'
  ensure
    Rake::Task['build:postgres:down'].invoke
  end
end

desc 'Push rubydata/discourse image'
task :push do
  sh 'docker', 'push', 'rubydata/discourse'
end

namespace :build do
  namespace :postgres do
    task up: 'compose:up:detached:postgres'
    task up: 'compose:up:detached:redis'
    task down: 'compose:down'
  end
end

namespace :compose do
  task :up do
    sh 'docker-compose', 'up'
  end

  namespace :up do
    namespace :detached do
      task :postgres do
        sh 'docker-compose', 'up', '-d', 'postgres'
      end

      task :redis do
        sh 'docker-compose', 'up', '-d', 'redis'
      end
    end
  end

  task :down do
    sh 'docker-compose', 'down'
  end
end
