# GiftListApp API

API to store and retrieve confidential giftlists (configuration, credentials)

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST  `api/v1/accounts`: Create a new account
- GET  `api/v1/giftlists/[list_id]/giftinfos/[info_id]`: Get a giftinfo
- GET  `api/v1/giftlists/[list_id]/giftinfos`: Get list of giftinfos for giftlist
- POST `api/v1/giftlists/[list_id]/giftinfos`: Upload giftinfo for a giftlist
- GET  `api/v1/giftlists/[list_id]`: Get information about a giftlist
- GET  `api/v1/giftlists`: Get list of all giftlists
- POST `api/v1/giftlists`: Create new giftlist

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this giftlist:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```