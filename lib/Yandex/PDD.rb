module Yandex

class PDD

	API_URL   = 'https://pddimp.yandex.ru/'

	TIMEOUT   = 10

	POP3_PORT = 110
	IMAP_PORT = 143

	POP3      = 'pop3'
	IMAP      = 'imap'

	IMPORT_METHOD       = POP3

    HTTP_ERROR          = 'HTTP_ERROR'

    NOT_AUTHENTICATED   = 'NOT_AUTHENTICATED'
    INVALID_RESPONSE    = 'INVALID_RESPONSE'
    REQUEST_FAILED      = 'REQUEST_FAILED'

    USER_NOT_FOUND      = 'USER_NOT_FOUND'
    LOGIN_OCCUPIED      = 'LOGIN_OCCUPIED'
    LOGIN_TOO_SHORT     = 'LOGIN_TOO_SHORT'
    LOGIN_TOO_LONG      = 'LOGIN_TOO_LONG'
    INVALID_LOGIN       = 'INVALID_LOGIN'

    INVALID_PASSWORD    = 'INVALID_PASSWORD'
    PASSWORD_TOO_SHORT  = 'PASSWORD_TOO_SHORT'
    PASSWORD_TOO_LONG   = 'PASSWORD_TOO_LONG'

    CANT_CREATE_ACCOUNT = 'CANT_CREATE_ACCOUNT'
    USER_LIMIT_EXCEEDED = 'USER_LIMIT_EXCEEDED'

    NO_IMPORT_SETTINGS  = 'NO_IMPORT_SETTINGS'

    SERVICE_ERROR       = 'SERVICE_ERROR'
    UNKNOWN_ERROR       = 'UNKNOWN_ERROR'

    ERR_R = {
                'not authenticated'           => NOT_AUTHENTICATED,
                'no_login'                    => INVALID_LOGIN,
                'bad_login'                   => INVALID_LOGIN,
                'no_user'                     => USER_NOT_FOUND,
                'not_found'                   => USER_NOT_FOUND,
                'user_not_found'              => USER_NOT_FOUND,
                'no such user registered'     => USER_NOT_FOUND,
                'occupied'                    => LOGIN_OCCUPIED,
                'login_short'                 => LOGIN_TOO_SHORT,
                'badlogin_length'             => LOGIN_TOO_LONG,
                'passwd-badpasswd'            => INVALID_PASSWORD,
                'passwd-tooshort'             => PASSWORD_TOO_SHORT,
                'passwd-toolong'              => PASSWORD_TOO_LONG,
                'hundred_users_limit'         => USER_LIMIT_EXCEEDED,

                'no-passwd_cryptpasswd'       => INVALID_PASSWORD,
                'cant_create_account'         => CANT_CREATE_ACCOUNT,

                'no_import_settings'          => NO_IMPORT_SETTINGS,
                'no import info on this user' => USER_NOT_FOUND,
                'unknown'                     => REQUEST_FAILED,
    }

	attr_accessor :request, :response
	attr_reader   :error,   :http_error

	def initialize(token, cert_file=nil)

		@token     = token
		@cert_file = cert_file
		@timeout   = TIMEOUT
	end

	def is_user_exists(login)

		url = API_URL + 'check_user.xml?token=' + @token + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		if ( result = get_node_text('/page/result') )

			return true  if ( 'exists' == result )
			return false if ( 'nouser' == result )
		end

		return unknown_error()
	end

    alias is_user_exists? is_user_exists

	def create_user(login, password, is_encrypted=false)

		url = API_URL

		if (is_encrypted)

			url += 'reg_user_crypto.xml?token=' + @token +  '&login='    + quote_encode(login)     +
														    '&password=' + quote_encode(password)
		else
			url += 'reg_user_token.xml?token='  + @token +  '&u_login='    + quote_encode(login)   +
															'&u_password=' + quote_encode(password)
		end

		return nil unless make_request(url)

		if ( uid = get_node_attr('/page/ok/@uid') )

			return uid
		end

		return unknown_error()
	end

	def create_user_encryped(login, password)

		return create_user(login, password, true)
	end

	def update_user(login, data)

		url = API_URL + 'edit_user.xml?token=' + @token    + '&login='    + quote_encode(login)           +
															 '&password=' + quote_encode(data[:password]) +
															 '&iname='    + quote_encode(data[:iname]   ) +
															 '&fname='    + quote_encode(data[:fname]   ) +
															 '&sex='      + quote_encode(data[:sex]     ) +
															 '&hintq='    + quote_encode(data[:hintq]   ) +
															 '&hinta='    + quote_encode(data[:hinta]   ) 
		return nil unless make_request(url)

		if ( uid = get_node_attr('/page/ok/@uid') )

			return uid
		end

		return unknown_error()
	end


	def delete_user(login)

		url = API_URL + 'delete_user.xml?token=' + @token  + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		return true if is_response_ok
		return unknown_error()
	end

	def get_unread_count(login)

		url = API_URL + 'get_mail_info.xml?token=' + @token + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		if ( count = get_node_attr('/page/ok/@new_messages') )

			return count
		end

		return unknown_error()
	end

	def set_forward(login, email, save_copy='no')

		save_copy = (save_copy and not 'no' == save_copy) ? 'yes' : 'no'

		url = API_URL + 'set_forward.xml?token=' + @token + '&login='   + quote_encode(login)   +
															'&address=' + quote_encode(address) +
															'&copy='    + save_copy

		return nil unless make_request(url)

		return true if is_response_ok
		return unknown_error()
	end

	def get_user(login)

		url = API_URL + 'get_user_info.xml?token=' + @token + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		user =
		{
			:domain      => get_node_text('/page/domain/name'),
			:login       => get_node_text('/page/domain/user/login'),
			:birth_date  => get_node_text('/page/domain/user/birth_date'),
			:fname       => get_node_text('/page/domain/user/fname'),
			:iname       => get_node_text('/page/domain/user/iname'),
			:hinta       => get_node_text('/page/domain/user/hinta'),
			:hintq       => get_node_text('/page/domain/user/hintq'),
			:mail_format => get_node_text('/page/domain/user/mail_format'),
			:charset     => get_node_text('/page/domain/user/charset'),
			:nickname    => get_node_text('/page/domain/user/nickname'),
			:sex         => get_node_text('/page/domain/user/sex'),
			:enabled     => get_node_text('/page/domain/user/enabled'),
			:signed_eula => get_node_text('/page/domain/user/signed_eula'),
		}

		return user
	end

	def get_user_list(page=1, per_page=100)

		url = API_URL + 'get_domain_users.xml?token=' + @token + '&page=%20'  + quote_encode(page)     +  # HACK XXX
																 '&per_page=' + quote_encode(per_page)

		return nil unless make_request(url)

		emails = []

		get_node('/page/domains/domain/emails/email/name').each do |n|

			emails.push(n.inner_xml) unless n.nil?
		end

		data =
		{
			:action_status    =>  get_node_text('/page/domains/domain/emails/action-status'),
			:found            =>  get_node_text('/page/domains/domain/emails/found'),
			:total            =>  get_node_text('/page/domains/domain/emails/total'),
			:domain           =>  get_node_text('/page/domains/domain/name'),
			:status           =>  get_node_text('/page/domains/domain/status'),
			:emails_max_count =>  get_node_text('/page/domains/domain/emails-max-count'),
			:emails           =>  emails,
		}

		return data
	end

	def prepare_import(server, data={})

        data[:method] = 'pop3' unless ( data[:method] and data[:method] !~ /^pop3|imap$/i )

		url = API_URL + 'set_domain.xml?token=' + @token  + '&ext_serv=' + server +
                                                            '&method='   + data[:method]

        url += '&ext_port=' + data[:port]     if ( data[:port] )   
		url += '&callback=' + data[:callback] if ( data[:callback] )

		url += '&isssl=no' unless ( data[:use_ssl] )

		return nil unless make_request(url)

		return true if is_response_ok
		return unknown_error()
	end

	def start_import(login, data)

		url = API_URL + 'start_import.xml?token=' + @token + '&login='     + quote_encode(login)          +
															 '&ext_login=' + quote_encode(data[:login])   +
															 '&password='  + quote_encode(data[:password])

		return nil unless make_request(url)

		return true
	end

	def import_user(login, password, data)

		data[:login]     ||= login
		data[:save_copy]   = ( data[:save_copy] ) ? 'yes' : '0'

		url = API_URL + 'reg_and_imp.xml?token=' + @token         +
						'&login='        + quote_encode(login)    +
						'&inn_password=' + quote_encode(password) +
						'&ext_login='    + quote_encode(data[:login])      +
						'&ext_password=' + quote_encode(data[:password])   +
						'&fwd_email='    + quote_encode(data[:forward_to]) +
						'&fwd_copy='     + quote_encode(data[:save_copy])

		return nil unless make_request(url)

		return true if is_response_ok
		return unknown_error()
	end

	def get_import_status(login)

		url = API_URL + 'check_import.xml?token=' + @token  + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		data =
		{
			:last_check => get_node_attr('/page/ok/@last_check'),
			:imported   => get_node_attr('/page/ok/@imported'),
			:state      => get_node_attr('/page/ok/@state'),
		}

		return data
	end

#	# fails for registered users
#	def import_imap_folder(login, data)
#
#		data[:login] ||= login
#	
#		my $url = API_URL + 'import_imap.xml?token=' + @token + '&login='           + quote_encode(login)           +
#																'&ext_login='       + quote_encode(data[:login])    +
##																'&int_password='    + quote_encode(password)        +
#																'&ext_password='    + quote_encode(data[:password]) +
#																'&copy_one_folder=' + quote_encode(data[:folder])
#		return nil unless make_request(url)
#
#		return true if is_response_ok
#		return unknown_error()
#	end

	def stop_import(login)

		return nil unless (login)

		url = API_URL + 'stop_import.xml?token=' + @token  + '&login=' + quote_encode(login)

		return nil unless make_request(url)

		return true if is_response_ok
		return unknown_error()
	end

private

	def reset_error

		@error      = nil
		@http_error = nil
	end

	def get_node(xpath, xml=nil)

		xml = @xml unless xml
		return xml.find(xpath)
	end

	def get_node_text(xpath, xml=nil)

		xml = @xml unless xml

		node = get_node(xpath, xml).first

		return nil if node.nil?
		return node.inner_xml
	end

	def get_node_attr(xpath, xml=nil)

		xml = @xml unless xml
		
		a = xml.find(xpath).first

		return nil if a.nil?
		return a.value
	end

    def identify_error(error)

            return ERR_R[ error.split(',').first ] || REQUEST_FAILED
    end

	def set_error(code, info, is_http=false)

		if (is_http)

			@error      = { :code => HTTP_ERROR }
			@http_error = { :code => code, :info => info }
		else

			@error      = { :code => code, :info => info }
			@http_error = nil
		end
	end

	def unknown_error

		set_error( UNKNOWN_ERROR, @response ? @response.body : '' )
		return nil
	end

	def handle_http_error

		set_error( @response.code, @response.body, true )
	end

	def handle_error

		set_error( identify_error( @_error ), @_error )
	end

	def parse_response

		@xml = LibXML::XML::Parser.string( @response.body ).parse

		if ( @_error = get_node_attr('/page/error/@reason') )

			handle_error()
			return nil
		end

		if ( get_node_attr('/page/xscript_invoke_failed/@error') )

			info = ''

			[ 'error', 'block', 'method', 'object', 'exception' ].each do |s|

				info += s + ': "' + get_node_attr('/page/xscript_invoke_failed/@' + s) + '" '
			end

			set_error(SERVICE_ERROR, info)
			return nil
		end

		return true

	rescue

		@xml = nil

		set_error(INVALID_RESPONSE, (@response) ? @response.body : '')
		return nil
	end

    def is_response_ok

        return not get_node('/page/ok').first.nil?
    end

    alias is_response_ok? is_response_ok

	def make_request(url)

		reset_error()

		@uri = URI::parse(url)

		@request = Net::HTTP::new(@uri.host, @uri.port)
		@request.open_timeout = @timeout
		@request.read_timeout = @timeout
		@request.use_ssl      = true

		if @cert_file

			@request.verify_mode = OpenSSL::SSL::VERIFY_PEER 
			@request.ca_file = @cert_file
		end

		@response = @request.get(@uri.request_uri)

		unless ( @response.is_a?(Net::HTTPSuccess) )

			handle_http_error()
			return nil
		end

		return parse_response()

	rescue Exception => e

		set_error(SERVICE_ERROR, e.to_s)
		return nil
	end

	def quote_encode(s)

		return s.to_s.gsub(/[^a-zA-Z0-9_\-.]/n){ sprintf("%%%02X", $&.unpack("C")[0]) }
	end

end
end

__END__

