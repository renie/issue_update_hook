require 'redmine'
require_dependency 'issue_update_hook'

RAILS_DEFAULT_LOGGER = Rails.logger unless defined? RAILS_DEFAULT_LOGGER
RAILS_DEFAULT_LOGGER.info 'Starting Redmine Post-Action Hooks'

Redmine::Plugin.register :redmine_post_action_hooks do
	name 'Update Issues Hook'
	author 'Renie Siqueira'
	description 'Hook for calling any URL when an issue gets up to date.'
	version '0.0.1'
end
