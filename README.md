# Google Directory API

## Description

Simple Google Directory API wrapper for Ruby on Rails. 
This relies on the [Google API Ruby Client](https://github.com/Omac/google-directory.git).

## Install

Add the gem to the Gemfile

```ruby
gem 'google-directory'
```

## Configuration

First configure your API in `initializers/google_directory.rb`

``` ruby
GoogleDirectory.configure do

	use_yaml Rails.root.join('config', 'google_directory.yaml')

	admin_email 'admin@domain.com'

	key_file Rails.root.join('config', 'keys', 'private_key.p12')

	key_passphrase 'notasecret'

	issuer 'xxxxxxx@developer.gserviceaccount.com'

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

### Multiple Google API access tokens using scopes

Specify a scope in the configuration `initializers/google_directory.rb`. 

``` ruby
GoogleDirectory.configure do

	use_yaml Rails.root.join('config', 'google_directory.yaml')

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
Keep in mind that the Token Store will be the same for all the scopes configured.

## Usage
``` ruby
google = GoogleDirectory::Client.new

google.find_users

google.create_user(email, "given_name", "family_name", "password")

google.update_user(email, update_data)

google.delete_user(email)

google.update_user_password(email, new_password)

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
* Implement more parameters from the Google API.
* Testing.