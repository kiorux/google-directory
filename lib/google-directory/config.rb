require 'yaml'

module GoogleDirectory
	
	class MissingConfiguration < StandardError
		def initialize
			super('No configuration found for Google Directory')
		end
	end

	class MissingYAMLConfiguration < StandardError
		def initialize
			super('No YAML configuration found for Google Directory')
		end
	end

	def self.configure(&block)
		@config = Config::Builder.new(&block).build
	end

	def self.configuration
		@config || (fail MissingConfiguration.new)
	end



	class Config

		attr_reader :admin_email, :key_passphrase, :issuer, :key_file, :scope_name

		def initialize(scope_name = :main)
			@scope_name = scope_name
		end

		def using(scope)
			@scopes[scope]
		end



		# token_type:
		# issued_at:
		# access_token:
		# expires_in:
		def save_token(token_hash)
			token_hash = token_hash.slice(:token_type, :issued_at, :access_token, :expires_in)
			@token_store and @token_store.save(@scope_name, token_hash)
		end

		def load_token
			@token_store and @token_store.load(@scope_name)
		end

		# def []( attribute )
		# 	return nil unless PUBLIC_ATTRS.include?(attribute)
		# 	instance_variable_get("@#{attribute}")
		# end

		class Builder
			
			def initialize(&block)
				@config = @current_config = Config.new
				@config.instance_variable_set('@scopes', { })
				instance_eval(&block)
			end

			def build
				@config
			end

			def use_yaml( yaml_file )
				
				File.exist?(yaml_file) || FileUtils.touch(yaml_file)
				@token_store = YamlTokenStore.new( yaml_file )
				@current_config.instance_variable_set('@token_store', @token_store)

			end

			def admin_email( admin_email )
				@current_config.instance_variable_set('@admin_email', admin_email)
			end

			def key_file( key_file )
				@current_config.instance_variable_set('@key_file', key_file)
			end

			def key_passphrase( key_passphrase )
				@current_config.instance_variable_set('@key_passphrase', key_passphrase)
			end

			def issuer( issuer )
				@current_config.instance_variable_set('@issuer', issuer)
			end

			def scope( scope_name, &block )
				scopes = @config.instance_variable_get('@scopes')
				scopes[scope_name] = @current_config = Config.new(scope_name)

				@current_config.instance_variable_set('@token_store', @token_store)

				instance_eval(&block)
				@current_config = @config
			end

		end

	end


	class YamlTokenStore

		def initialize(yaml_file)
			@yaml_file = yaml_file
			@yaml_data = YAML::load( yaml_file.open )
			@yaml_data = {} unless @yaml_data.is_a?(Hash)
			# @yaml_data[Rails.env.to_s] ||= {}
		end

		def save( scope_name, token_hash )
			data = (@yaml_data[Rails.env.to_s] ||= {})
			data[scope_name.to_s] = token_hash.stringify_keys
			File.open(@yaml_file, 'w') { |file| file.write( YAML::dump(@yaml_data) ) }
		end

		def load( scope_name )
			data = @yaml_data[Rails.env.to_s] and data = data[scope_name.to_s] and data.symbolize_keys.slice(:token_type, :issued_at, :access_token, :expires_in)
		end

	end


end