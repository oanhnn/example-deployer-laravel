# Example deployer

This is an example deploy [Laravel] project on [Ubuntu] 16.04 LTS using [Deployer]

> Local computer run Linux, MacOS or Windows (Git bash)

## Requirement

1. Make a VPS run Ubuntu 16.04 LTS
2. Point your domain to your VPS

## Setup server

1. Make file `setup/.env` (copy from `setup/.env.example`) and fill your server configuration
2. Upload all `setup` directory to server by `scp`

   ```bash
   $ scp -r ./setup root@xx.xx.xx.xx:~/
   ```
   
3. SSH to server with root account (or using `sudo su`) and execute `.sh` scripts in order (from 01 to 30)

## Deploy

1. Copy your `.env` and `laravel-echo.json` to `shared` directory
2. Configure your hosts to `hosts.yml` (copy from `hosts.yml.example`)
3. Install all dependencies by `composer install` command

   ```bash
   $ composer install
   ```

4. Run `deploy:configure` task on the first deploy

   ```bash
   $ ./vendor/bin/dep deploy:configure production
   ```

5. Run `deploy` task

   ```bash
   $ ./vendor/bin/dep deploy production
   ```

## Note

1. Run Deployer with option `-vvv` for debug mode
2. You should configure SSH key and deploy key before run deploy
3. If your Laravel application using Laravel Echo Server, Queue or Schedule, 
   you should execute necessary script for your special stack

## Changelog

See all change logs in [CHANGELOG](CHANGELOG.md)

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) for details.

## Security

If you discover any security related issues, please email to [Oanh Nguyen](mailto:oanhnn.bk@gmail.com) instead of 
using the issue tracker.

## Credits

- [Oanh Nguyen](https://github.com/oanhnn)
- [All Contributors](../../contributors)

## License

This project is released under the MIT License.   
Copyright © 2017-2018 [Oanh Nguyen](https://oanhnn.github.io/).

[Deployer]: https://deployer.org
[Laravel]:  https://laravel.com
[Ubuntu]:   https://ubuntu.com
