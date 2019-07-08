# Control Center API

It includes the following features:

* API DSL based on Grape micro-framework
* ActiveRecord for models
* Active record migrations - see rake file
* Simplified console

## Manual Setup

### System Dependencies
* ruby 2.3.1

# Setup

create the databases with `bundle exec rake db:create db:migrate`.

### DB

The aplication database is configured in a standard way using `database/config.yml` which provides settings for different environments.

### Console

run `bin/console`

### Up and running

`bin/dev`

### Testing

run the entire test suite:

run `bundle exec rspec`

you can run individual test suites by specifying the filename in the run command:

run `bundle exec rspec spec/path/to/spec.rb`

## Services

Services are a first-class citizen in our application. Their purpose is to encapsulate common business processes. These typically involve creating set of models, tracking events, or sending emails, notifications etc. In order to build a composable system there are a number of conventions that should be enforced while using them:

* Transactional execution - every service is by default wrapped in an ActiveRecord::Base.transaction block to ensure it was either executed fully or all changes were reverted. Please note, that not every action can be reverted - sending emails, tracking mixpanel data etc. - for that reason, we should create ActiveRecord objects first to make sure all the data went through. Alternatively, raise an exception if something goes wrong.

* Parameters validation - the parameters for the service should be validated (grape validations or any other way e.g. defautl_params and santazied_params helpers) before the execution of the service is triggered. That way, services can focus purely on business logic and fail quickly in case something goes wrong.

* Return types - where possible return simple data as the result of the service call. Any data structure which can be serialized as JSON can be considered such. Returning instances of models is discouraged as it allows further mutable operations on the returned object outside of the service layer.

## Helpers

* Execution - Services can be executed from any API class with the `service(:service_name, params, :api_name)` helper. The helper will look for the appropriate class, require the needed file and execute it. In order to make sure only valid data goes to the service `declared_params`is strongly prefered.

## MailCatcher 

A simple SMTP server which catches any message sent to it to display in a web interface. To get started:

run `gem install mailcatcher`

run `mailcatcher`

then check out http://127.0.0.1:1080 to see the mail that's arrived so far.# control-center-api
