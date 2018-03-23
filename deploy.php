<?php
namespace Deployer;

require 'recipe/laravel.php';
require 'recipe/npm.php';

// Project name
//set('application', 'exmaple.com');

// Project repository
//set('repository', 'git@gitlab.com:vendor/exmaple.git');

// Deploy path
set('deploy_path', '/apps/{{domain}}');

// [Optional] Allocate tty for git clone. Default value is false.
set('git_tty', false);

// Shared files/dirs between deploys
add('shared_files', []);
add('shared_dirs', []);

// Writable dirs by web server
add('writable_dirs', []);

// Hosts
inventory('hosts.yml');

// Tasks
task('deploy:configure', function () {
    run('mkdir -p {{deploy_path}}/shared');
    upload('shared/', '{{deploy_path}}/shared');
});

// [Optional] if deploy fails automatically unlock.
//after('deploy:failed', 'deploy:unlock');

// [Optional] install & build assets after update code
after('deploy:update_code', 'npm:install');

// [Optional] Migrate database before symlink new release.
before('deploy:symlink', 'artisan:migrate');
