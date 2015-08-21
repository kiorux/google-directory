require "google-directory/version"
require "google-directory/config"
require 'google/api_client'

module GoogleDirectory

	class Client

		attr_reader :directory_api, :client, :config, :result

		def initialize(scope = :main)
			@config = GoogleDirectory.configuration
			@config = @config.using(scope) if @config.scope_name != scope

			
			@key = Google::APIClient::KeyUtils.load_from_pkcs12(@config.key_file, @config.key_passphrase)
			@client = Google::APIClient.new(:application_name => @config.application_name, :application_version => @config.application_version )

			@client.authorization = Signet::OAuth2::Client.new(
				:token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
				:audience => 'https://accounts.google.com/o/oauth2/token',
				:scope => 'https://www.googleapis.com/auth/admin.directory.user',
				:issuer => @config.issuer, 
				:person => @config.admin_email,
				:signing_key => @key
			)

			if token = @config.load_token

				token['issued_at'] = Time.parse( token['issued_at'] )
				@client.authorization.update_token!(token)

			else
				token = @client.authorization.fetch_access_token!
				token['issued_at'] = @client.authorization.issued_at.to_s
				@config.save_token(token)

			end
			
			@directory_api = @client.discovered_api('admin', 'directory_v1')
		end


		def find_users(params)
			execute(:api_method => directory_api.users.list, :parameters => params)
		end

		def find_user_by_email(email)
			execute(:api_method => directory_api.users.get, :parameters => { 'userKey' => email })
		end

		#
		# https://developers.google.com/admin-sdk/directory/v1/reference/users/insert
		#
		def create_user(email, given_name, family_name, password, opts = {})
			opts = {
				'name'                       => { 'givenName' => given_name, 'familyName' => family_name},
				'password'                   => password,
				'primaryEmail'               => email,
				'changePasswordAtNextLogin'  => true
			}.merge(opts)

			execute(:api_method => directory_api.users.insert, :body_object => opts)
		end

		def delete_user(email)
			execute(:api_method => directory_api.users.delete, :parameters => {'userKey' => email})
		end

		def update_user(email, update_data = {})
			execute(:api_method => directory_api.users.update, :parameters => {'userKey' => email}, :body_object => update_data)
		end

		def update_user_password(email, password)
			update_user(email, {'password' => password, 'changePasswordAtNextLogin' => false})
		end

		private 

			def execute(opts)
				if client.authorization.expired?
					token = client.authorization.refresh!
					token['issued_at'] = client.authorization.issued_at.to_s
					config.save_token(token)
				end

				@result = client.execute(opts)
				
				case result.status
				when 204 then return true
				when 404 then return false
				when 200 then return JSON.parse(result.body)
				end

				Rails.logger.error("== Google ERROR ==\n\t- execute(#{opts})\n\t- response:\n#{result.response.to_yaml}")

				false
			end
	end

end