# Hyku, the Hydra-in-a-Box Repository Application

Code:
[![Build Status](https://circleci.com/gh/samvera/hyku.svg?style=svg)](https://circleci.com/gh/samvera/hyku)
[![Coverage Status](https://coveralls.io/repos/samvera/hyku/badge.svg?branch=master&service=github)](https://coveralls.io/github/samvera/hyku?branch=master)
[![Stories in Ready](https://img.shields.io/waffle/label/samvera/hyku/ready.svg)](https://waffle.io/samvera/hyku)

Docs:
[![Documentation](http://img.shields.io/badge/DOCUMENTATION-wiki-blue.svg)](https://github.com/samvera/hyku/wiki)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Jump In: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

----
## Table of Contents

  * [Running the stack](#running-the-stack)
    * [Important URL's](#important-urls)
    * [Dory](#dory)
    * [With Docker](#with-docker)
      * [Install Docker](#install-docker)
      * [Start the server](#start-the-server)
      * [Seed the database](#seed-the-database)
      * [Access the container](#access-the-container)
      * [Stop the app and services](#stop-the-app-and-services)
      * [Troubleshooting](#troubleshooting)
      * [Rubocop](#rubocop)
    * [Without Docker](#without-docker)
      * [For development](#for-development)
      * [For testing](#for-testing)
    * [Working with Translations](#working-with-translations)
    * [On AWS](#on-aws)
    * [With Vagrant](#with-vagrant)
    * [With Kubernetes](#with-kubernetes)
  * [Single Tenant Mode](#single-tenancy)
  * [Switching accounts](#switching-accounts)
  * [Development dependencies](#development-dependencies)
    * [Postgres](#postgres)
  * [Importing](#importing)
    * [Enable Bulkrax](#bulkrax)
    * [From CSV](#from-csv)
    * [From purl](#from-purl)
  * [Compatibility](#compatibility)
  * [Product Owner](#product-owner)
  * [Help](#help)
  * [Acknowledgments](#acknowledgments)

----

## Running the stack
### Important URL's
- Local site:
  - With dory: hyku.test
  - Without dory: localhost:3000
- Production site: http://iro.bl.uk/
- Solr: http://solr.hyku.test

### Dory
On OS X or Linux we recommend running [Dory](https://github.com/FreedomBen/dory). It acts as a proxy allowing you to access domains locally such as hyku.test or tenant.hyku.test, making multitenant development more straightforward and prevents the need to bind ports locally. Be sure to [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file).

You can still run in development via docker with out Dory, but to do so please uncomment the ports section in docker-compose.yml

```bash
gem install dory
dory up
```

### With Docker
We distribute two configuration files:
- `docker-compose.yml` is set up for development / running the specs
- `docker-compose.production.yml` is for running the Hyku stack in a production setting

#### Install Docker
- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in

#### If this is your first time working in this repo or the Dockerfile has been updated you will need to pull your services first
  ```bash
  docker-compose pull
  docker-compose build
  ```

#### Start the server
```bash
docker-compose up web workers
```
This command starts the web and workers containers allowing Rails to be started or stopped independent of the other services. Once that starts (you'll see the line `Listening on tcp://0.0.0.0:3000` to indicate a successful boot), you can view your app at one of the [dev URL's](#important-urls) above.

#### Seed the database
```bash
sc be rails db:seed
```

#### Access the container
- In a separate terminal window or tab than the running server, run:
  ``` bash
  dc exec web bash
  ```

- You need to be inside the container to:
  - Access the rails console for debugging
  ``` bash
  rails c
  ```

  - Run [rspec](https://github.com/rspec/rspec-rails/tree/4-1-maintenance#running-specs)
  ``` bash
  rspec
  ```

#### Stop the app and services
- Press `Ctrl + C` in the window where `docker-compose up web workers` is running
- When that's done `docker-compose stop` shuts down the running containers
- `dory down` stops Dory

#### Troubleshooting
- Was the Dockerfile changed on your most recent `git pull`? Refer to the instructions above
- Double check your dory set up

- Error: `No such file or directory @ rb_sysopen - /app/samvera/hyrax-webapp/log/indexing.log`
- Solution:
  ``` bash
  mkdir /app/samvera/hyrax-webapp/log
  touch /app/samvera/hyrax-webapp/log/indexing.log
  ```
#### Rubocop
Rubocop can be run in docker locally using either of the options below:
- Outside the container:
  ```bash
  docker-compose exec web rake
  ```
- Inside the container: (learn about the `-a` flag [here](https://docs.rubocop.org/rubocop/usage/basic_usage.html#auto-correcting-offenses))
  ```bash
  rubocop -a
  ```

### Without Docker
#### For development

```bash
solr_wrapper
fcrepo_wrapper
postgres -D ./db/postgres
redis-server /usr/local/etc/redis.conf
bin/setup
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0
```
#### For testing

See the [Hyku Development Guide](https://github.com/samvera/hyku/wiki/Hyku-Development-Guide) for how to run tests.

### Working with Translations

You can log all of the I18n lookups to the Rails logger by setting the I18N_DEBUG environment variable to true. This will add a lot of chatter to the Rails logger (but can be very helpful to zero in on what I18n key you should or could use).

```console
$ I18N_DEBUG=true bin/rails server
```

### On AWS

AWS CloudFormation templates for the Hyku stack are available in a separate repository:

https://github.com/hybox/aws

### With Vagrant

The [samvera-vagrant project](https://github.com/samvera-labs/samvera-vagrant) provides another simple way to get started "kicking the tires" of Hyku (and [Hyrax](http://hyr.ax/)), making it easy and quick to spin up Hyku. (Note that this is not for production or production-like installations.) It requires [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/).

### With Kubernetes

Hyku provides a set of [Helm charts](chart/README.md) for deploying to a Kubernetes cluster. Detailed instructions are provided for deploying locally with Docker for Mac.

## Single Tenant Mode

Much of the default configuration in Hyku is set up to use multi-tenant mode.  This default mode allows Hyku users to run the equivielent of multiple Hyrax installs on a single set of resources. However, sometimes the subdomain splitting multi-headed complexity is simply not needed.  If this is the case, then single tenant mode is for you.  Single tenant mode will not show the tenant sign up page, or any of the tenant management screens. Instead it shows a single Samvera instance at what ever domain is pointed at the application.

To enable single tenant, in your settings.yml file change multitenancy/enabled to `false` or set `SETTINGS__MULTITENANCY__ENABLED=false` in your `docker-compose.yml` and `docker-compose.production.yml` configs. After changinig this setting, run `rails db:seed` to prepopulate the single tenant.

In single tenant mode, both the application root (eg. localhost, or hyku.test) and the tenant url single.* (eg. single.hyku.test) will load the tenant. Override the root host by setting multitenancy/root_host in settings.yml or `SETTINGS__MULTITENANCY__ROOT_HOST`.

To change from single- to multi-tenant mode, change the multitenancy/enabled flag to true and restart the application. Change the 'single' tenant account cname in the Accounts edit interface to the correct hostname.

## Switching accounts

The recommend way to switch your current session from one account to another is by doing:

```ruby
AccountElevator.switch!('repo.example.com')
```

## Development Dependencies

### Postgres

Hyku supports multitenancy using the `apartment` gem. `apartment` works best with a postgres database.

## Importing
### Enable Bulkrax:

- Set bulkrax -> enabled to true in settings (via file or env variable)
- Add `  require bulkrax/application` to app/assets/javascripts/application.js and app/assets/stylesheets/application.css files.

(in a `docker-compose exec web bash` if you're doing docker otherwise in your terminal)
```bash
bundle exec rails db:migrate
```

### From CSV:

```bash
./bin/import_from_csv localhost spec/fixtures/csv/gse_metadata.csv ../hyku-objects
```

### From purl:

```bash
./bin/import_from_purl ../hyku-objects bc390xk2647 bc402fk6835 bc483gc9313
```

## Compatibility

* Ruby 2.4 or the latest 2.3 version is recommended.  Later versions may also work.
* Rails 5 is required. We recommend the latest Rails 5.1 release.

### Product Owner

[orangewolf](https://github.com/orangewolf)

## Help

The Samvera community is here to help. Please see our [support guide](./SUPPORT.md).

## Acknowledgments

This software was developed by the Hydra-in-a-Box Project (DPLA, DuraSpace, and Stanford University) under a grant from IMLS.

This software is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
