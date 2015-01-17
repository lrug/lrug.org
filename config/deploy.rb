# config valid only for current version of Capistrano
lock '3.3.5'

set :application, "lrug.org"
set :deploy_to, "/home/lrug/sites/lrug.org/new"
set :scm, :copy
set :use_sudo, false
set :domain, 'lrug.org'
set :user, 'lrug'
set :include_dir, 'public'
set :tar_roles, :all

before :deploy, :update_code do
  run_locally do
    execute :rm, '-rf', 'public/*'
    execute :bundle, 'exec', 'middleman', 'build', ';', 'true'
  end
end

after :deploy, :create_release do
  on roles(fetch(:tar_roles, :all)) do
    # Clear up OS X resource fork spoor files
    execute :find, "#{release_path}/public", '-name', '"._*"', '-print0', '|', 'xargs', '-0', 'rm'
    execute :rm, '-f', "#{release_path}/._public"
  end
end
