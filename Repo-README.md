# British Libraries

---

## Table of Contents

- [Running the stack](#running-the-stack)
  - [Important URL's](#important-urls)
  - [Dory](#dory)
  - [With Docker](#with-docker)
    - [Install Docker](#install-docker)
    - [Start the server](#start-the-server)
    - [Seed the database](#seed-the-database)
    - [Access the container](#access-the-container)
    - [Stop the app and services](#stop-the-app-and-services)
    - [Troubleshooting](#troubleshooting)
    - [Rubocop](#rubocop)
  - [Working with Translations](#working-with-translations)
- [Admin User](#admin-user)
- [Account (tenant) Creation](#account-tenant-creation)
- [Rescue Server Deploy](#rescue-server-deploy)
- [Single Tenant Mode](#single-tenancy)
- [Switching accounts](#switching-accounts)
- [Importing](#importing)
  - [Enable Bulkrax](#enable-bulkrax)
  - [Disable Bulkrax](#disable-bulkrax)
  - [Create an Importer](#create-an-importer)
- [DOI](#doi)
  - [Reading](#reading)
  - [Minting](#minting)

---

## Running the stack

### Important URL's

- Local site:
  - With dory: admin.bl.test
  - Without dory: localhost:3000
- Staging site: http://bl-staging.notch8.cloud/
- Production site: http://iro.bl.uk/
- Solr: http://solr.bl.test
  - Check the `SOLR_ADMIN_USER` and `SOLR_ADMIN_PASSWORD` in "docker-compose.yml"
- Sidekiq: http://bl.test/sidekiq

### Dory

On OS X or Linux we recommend running [Dory](https://github.com/FreedomBen/dory). It acts as a proxy allowing you to access domains locally such as bl.test or tenant.bl.test, making multitenant development more straightforward and prevents the need to bind ports locally. Be sure to [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file).

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

#### If this is your first time working in this repo recently, you may have remnants of an old setup that requires a few extra commands

```bash
docker compose down -v
rm -rf solr_db_initialized
#verify that the solr_db_initialized is actually gone
ls
docker compose build --no-cache
docker compose up
dory up
```

#### If this is your first time working in this repo ever, you can use just the following

```bash
docker compose build --no-cache
docker compose up
dory up
```

#### If your Dockerfile has been updated, you may need to rebuild

```bash
docker compose down -v
docker compose build --no-cache
docker compose up
dory up
```

#### If you just want to start the server

```bash
docker compose up
dory up
```

This command starts the web and worker containers allowing Rails to be started or stopped independent of the other services. You can now view your app at one of the [dev URL's](#important-urls) above.

#### Seed the database and/or a superadmin

if you want to automatically create a dataset, place the exported file in data/ before beginning. These files should not be added to the repo as they are often quite large.

```bash
sc be rails db:seed
```

When you first rebuild your app after removing all the volumes, you may need to seed a superadmin

```bash
docker compose exec web bash
rake hyku:superadmin:create
```

#### Access the container

- In a separate terminal window or tab than the running server, run:

  ```bash
  sc sh
  ```

  or

  ```bash
  docker compose exec web bash
  ```

- You need to be inside the container to:

  - Access the rails console for debugging

  ```bash
  rails c
  ```

  - Run [rspec](https://github.com/rspec/rspec-rails/tree/4-1-maintenance#running-specs)

  ```bash
  rspec
  ```

#### Set up the app routes the same way as its set up in production

1. Create a tenant called 'search' and check the box below make it search-only
2. Change the cname of the search tenant

```bash
docker compose exec web bash
rails c
search_account = Account.find_by(cname: "search.bl.test")
search_account.update(cname: 'bl.test')
```

3. if you'd like to use the logo links on the shared homepage, you can create tenants called 'mola', 'nms', 'bl', 'kew', 'tate', or 'britishmuseum'

#### Stop the app and services

- Press `Ctrl + C` in the window where `sc up` is running
- When that's done `sc stop` shuts down the running containers
- `dory down` stops Dory

#### Troubleshooting

- Was the Dockerfile changed on your most recent `git pull`? Refer to the instructions above
- Double check your dory set up

- Issue: `No such file or directory @ rb_sysopen - /app/samvera/hyrax-webapp/log/indexing.log`
- Try:

  ```bash
  mkdir /app/samvera/hyrax-webapp/log
  touch /app/samvera/hyrax-webapp/log/indexing.log
  ```

- Issue: Could not find <gem> in any of the sources (Bundler::GemNotFound)
- Try:

  ```bash
  docker compose down -v
  docker compose build --no-cache
  docker compose up
  dory up
  ```

- Issue: Want to follow the logs during the `initialize_app` phase
- Try: `dc logs -f initialize_app`

- Issue: Sidekiq isn't working (e.g.: importer/exporter status stays stuck at "pending")
- Try:
  ```bash
  docker-compose exec web bash # or `sc sh`
  bundle exec sidekiq
  ```

#### Rubocop

Rubocop can be run in docker locally using either of the options below:

- Outside the container:
  ```bash
  sc be rake
  ```
- With autocorrect: (learn about the `-a` flag [here](https://docs.rubocop.org/rubocop/usage/basic_usage.html#auto-correcting-offenses))
  ```bash
  sc exec rubocop -a
  ```
- Inside the container:
  ```bash
  rubocop -a
  ```

### Working with Translations

You can log all of the I18n lookups to the Rails logger by setting the I18N_DEBUG environment variable to true. This will add a lot of chatter to the Rails logger (but can be very helpful to zero in on what I18n key you should or could use).

```console
$ I18N_DEBUG=true bin/rails server
```

## Admin User

This is for the admin login on the Shared Research Repository page or when logging in to a specific tenant

- Local: `INITIAL_ADMIN_EMAIL` and `INITIAL_ADMIN_PASSWORD` in ".env"
- Staging: `INITIAL_ADMIN_EMAIL` and `INITIAL_ADMIN_PASSWORD` in "staging-deploy.yaml"

## Account (tenant) creation

- From the home page click on "Accounts" in the upper left corner
- Press "Create New Account"
- Give the account a short name
- Access the tenant at "<short-name>.bl.test"
  NOTE: Although there are institutional logo's on the home page, all accounts are not created by default. If you would like to create an account for one of them, hover over its logo to see the url in the bottom left corner of the screen. Use the subdomain as the "short name" in the process above.
- Check the `authenticate_if_needed` method in application_controller.rb for the current username/password combination

# Search only tenant creation

- From the home page click on "Accounts" in the upper left corner
- Press "Create New Account"
- Select the check box for "search only account"
- Name the tenant 'search' if you would like to use it to execute searches from the splash page (bl.test)
- After clicking 'Save', select the button that says 'Edit Account'
- Scroll down to the 'Add Accounts' section
- Add any accounts you would like to include in the shared search
  - If there is any text in the 'Solr URL' field, make sure to delete it. Save your edits.
- You will likely need to reindex your works in order to make them searchable
  ```bash
  docker-compose exec web bash
  rails hyku:reindex_works
  ```
- Visit bl.test
- Execute a search from the search bar to check that your tenant works.

## Rescue Server Deploy

- This is a single large box with everything running in docker-compose. All files for the app are at `/data/bl-transfer`
- Tmux on this box uses default settings; "ctrl-b" is the leader command
- Your ssh key should work
- This attaches to a shared session so you can see if anyone is running a special job and we don't step on each other
- If we have to run a migration or do something else that may make this process take a while, run `cp public/maintenance.html public/under_maintenance.html` after `dc build web`

```bash
ssh -t azureuser@51.140.4.10 "tmux new-session -A -s main"
cd /data/bl-transfer
git pull gitlab main
dc build web
dc build worker
dc up -d web
dc exec web bash -l -c "DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile && bundle exec pumactl restart -p 1"
```

## Single Tenant Mode

Much of the default configuration in Hyku is set up to use multi-tenant mode. This default mode allows Hyku users to run the equivielent of multiple Hyrax installs on a single set of resources. However, sometimes the subdomain splitting multi-headed complexity is simply not needed. If this is the case, then single tenant mode is for you. Single tenant mode will not show the tenant sign up page, or any of the tenant management screens. Instead it shows a single Samvera instance at what ever domain is pointed at the application.

To enable single tenant, in your settings.yml file change multitenancy/enabled to `false` or set `HYKU_MULTITENAN=false` in your `docker-compose.yml` and `docker-compose.production.yml` configs. After changinig this setting, run `rails db:seed` to prepopulate the single tenant.

In single tenant mode, both the application root (eg. localhost, or bl.test) and the tenant url single.\* (eg. single.bl.test) will load the tenant. Override the root host by setting multitenancy/root_host in settings.yml or `HYKU_ROOT_HOST`.

To change from single- to multi-tenant mode, change the multitenancy/enabled flag to true and restart the application. Change the 'single' tenant account cname in the Accounts edit interface to the correct hostname.

## Switching accounts

There are multiple ways to switch your current session from one account to another:

```ruby
switch!(Account.first)
# or
switch!('my.site.com')
# or
switch!('myaccount')

```

## Importing

### Enable Bulkrax:

- Change `HYKU_BULKRAX_ENABLED` to `true` in ".env"
- Change `//require bulkrax/application` to `//= require bulkrax/application` in "application.js"
- Change `require bulkrax/application` to `*= require bulkrax/application` in "application.css"
- Change `HYKU_BULKRAX_ENABLED` to `true` in "docker-compose.yml" (it's in there more than once)
- Change the value under `name: HYKU_BULKRAX_ENABLED` to `true` in "staging-deploy.yaml" (it's in there more than once)
- Restart the server

### Disable Bulkrax:

- Revert each of the changes above
- Restart the server

### Create an Importer

- Choose "Importers" from the left navbar
- Click "New"
- Fill in the required fields
  (Refer to this [Wiki article](https://github.com/samvera-labs/bulkrax/wiki/Bulkrax-User-Interface---Importers) for more details about the fields and save options)

## DOI

[What is a DOI?](https://datacite.org/dois.html)

### Reading

#### Enabling

Reading a DOI will find the associated metadata for that object on DataCite and override the fields on your work with that data.

- Sign in to the admin dashboard
- Click Settings >> Account on the left navigation pane
- Check the box that says "DOI reader"
- Save changes

#### Using

TODO

### Minting

#### Enabling

Minting a DOI will create a new entry on DataCite with the information from your work.

- Go to the Accounts page to edit the mola tenant
- Scroll down to the DataCite Endpoint section and input the following info
  - Mode: test
  - Prefix: 10.21259
  - Username: RYUN.ZEOJHG
  - Password: Acquaint5Reboot$showplace
- Save changes
- Sign in to the admin dashboard
- Click Settings >> Account on the left navigation pane
- Check the box that says "DOI minting"
- Save changes

#### Using

- When creating or editing a work, you should see a tab that says "DOI"
- Click the "Create draft DOI" button
- Select any of the radio buttons (registered and findable can never be removed from DataCite):
  - do not mint
  - draft
  - registered
  - findable
- Edit and save your work as normal
