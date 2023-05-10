# Giftlist API
API to store and retrieve confidential development files (configuration, credentials)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/list_doc/`: returns all confiugration IDs
- GET `api/v1/list_doc/[ID]`: returns details about a single document with given ID
- POST `api/v1/list_doc/`: creates a new document

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
rake spec
```

## Execute

Run this API using:

```shell
rake run:dev
```
