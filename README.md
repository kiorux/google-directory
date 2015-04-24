# Google Directory API

## Description

Simple Google Directory API wrapper for Ruby on Rails. 
This relies on the [Google API Ruby Client](https://github.com/google/google-api-ruby-client).

**This library is in alpha. Future incompatible changes may be necessary.**

## Requirements 

* An active project in the Google Developers Console.
* A service-to-service Client ID. [How to](https://developers.google.com/console/help/new/#serviceaccounts).
* A valid P12 key.
* The Admin SDK enabled.
* Authorization from the Google Apps Admin Console to the Client ID to access the scope `https://www.googleapis.com/auth/admin.directory.user`.

## Install

Add the gem to the Gemfile

```ruby
gem 'google-directory'
```

## Configuration

First configure your API in `config/initializers/google_directory.rb`

``` ruby
GoogleDirectory.configure do
	
	# OPTIONAL. Use a YAML file to store the requested access tokens. When the token is refreshed, this file will be updated.
	use_yaml Rails.root.join('config', 'google_directory.yaml')

	# Required attributes
	admin_email      'admin@domain.com'
	key_file         Rails.root.join('config', 'keys', 'private_key.p12')
	key_passphrase   'notasecret'
	issuer           'xxxxxxx@developer.gserviceaccount.com'

	# Optional attributes
	application_name    'My Application'
	application_version '1.0.0'

end
```

Using YAML as the Token Store will create a file with the access tokens. The gem will refresh the token automatically when after they expire and it will rewrite the new access token to the YAML file. Producing something like this:

``` yaml
development: 
  scope:
    token_type: Bearer
    issued_at: ISSUED_DATE
    access_token: ACCESS_TOKEN
    expires_in: 3600
```

### Multiple API clients using scopes

Specify a scope in the configuration `config/initializers/google_directory.rb`. 

``` ruby
GoogleDirectory.configure do

	scope :domain_one do
		admin_email 'admin@domain_one.com'
		# [...]
	end

	scope :domain_two do
		admin_email 'admin@domain_two.com'
		# [...]
	end

end
```

## Usage

``` ruby
google = GoogleDirectory::Client.new

google.find_users

google.create_user("email", "given_name", "family_name", "password")

google.update_user("email", update_data)

google.delete_user("email")

google.update_user_password("email", "new_password")

```

### Multiple Scopes

``` ruby
domain_one = GoogleDirectory::Client.new(:domain_one)
domain_one.find_users

domain_two = GoogleDirectory::Client.new(:domain_two)
domain_two.find_users
```

## TO DO

* `use_active_model` for database token store.
* Build the configuration generator.
* Implement more parameters and calls to the Admin SDK.
* Better error handling.
* Documentation.
* Testing.