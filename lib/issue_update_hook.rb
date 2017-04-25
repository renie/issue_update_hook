require "uri"
require "net/https"
require "json"

class RedminePostActionHooks < Redmine::Hook::Listener
	@@url = nil
	@@relevant_status = nil
	@@issue = nil
	@@relevant_projects = nil

	
	def controller_issues_edit_after_save(context = { })
		load_config()
		@@issue = context[:issue]
		send_request(create_object_from_issue()) if should_send?
	end


# =================


	def should_send?()
		return (is_relevant_status_change? && belongs_to_relevant_project?)
	end

	def is_relevant_status_change?()
		return @@relevant_status.include? @@issue.status_id
	end

	def belongs_to_relevant_project?()
		return @@relevant_projects.include? @@issue.project_id
	end
	
	def load_config()
		options = YAML::load(File.open(File.join(Rails.root, 'plugins', 'issue_update_hook', 'conf', 'talk_update_issue_hook_config.yml')))
		@@url = options['url']
		@@relevant_status = options['relevant_status']
		@@relevant_projects = options['relevant_projects']
		@@fields_needed = options['fields_needed']
	end

	def send_request(data)
		header = {'Content-Type': 'application/json'}
		
		begin
			uri = URI.parse(@@url)
			http = Net::HTTP.new(uri.host, uri.port)

            if uri.scheme == "https"
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end

			request = Net::HTTP::Post.new(uri.request_uri, header)
			request.body = data
		
			res = http.request(request)
            RAILS_DEFAULT_LOGGER.info "URL called: #{@@url}. Data: #{data}"
			RAILS_DEFAULT_LOGGER.warn "Issue update hook: Failed to dispath information, server returned status #{res.code}: #{res.msg}" unless res.kind_of? === Net::HTTPSuccess
		rescue Exception => e
			RAILS_DEFAULT_LOGGER.warn "Issue update hook: Caught an Exception: #{e.class} with message \"#{e.message}\""
		end
	end

	def create_object_from_issue()
		return get_fields().to_json()
	end
	
	def exists_on_issue?(field_name)
		return (@@issue.respond_to?(field_name.to_sym()) ||
				 @@issue.respond_to?(field_name.split('.')[0].to_sym())) 
	end

	def get_fields()
		fields = Hash.new
		@@fields_needed.each {|f| fields[f] = if exists_on_issue?(f) then get_field(f) else get_custom_field(f) end}

		return fields
	end

	def get_field(field_name)
		expression = '@@issue'
		field_name.split('.').each {|s| expression += ".send(:#{s})" }

		return eval(expression)
	end

	def get_custom_field(field_name)
		field = @@issue.custom_field_values.detect {|v| v.custom_field.name == field_name }

		return field ? field.value : nil
	end
end
