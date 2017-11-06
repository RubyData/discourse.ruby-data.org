namespace :discourse do
  desc "pull discourse image"
  task 'pull' do
    on roles(:app) do |server|
      execute 'docker', 'pull', 'rubydata/discourse', '|tee'
    end
  end
end
