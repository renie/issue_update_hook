# Redmine Issue Update Hook

## Get Started

- Download this project on `<redmine_root_path>/plugins`
  ```
  cd <redmine_root_path>/plugins
  git clone https://github.com/renie/issue_update_hook.git
  ```
- Customize your configs on `<redmine_root_path>/plugins/issue_update_hook/talk_update_issue_hook_config.yml`
- Restart your Redmine

## Possible configs

- url [string]:
	- **External application's URL** to be called on issue update (https is supported)
	- e.g.: http://myhost/my/nice/endpoint
- relevant_status [array]:
	- Request happens only if **status id** is on this Array
	- e.g.: [2,5]
- relevant_projects [array]:
	- Request happens only if **project id** is on this Array
	- e.g.: [8]
- fields_needed [list]:
	- Request happens only if **project id** is on this Array
	- e.g.:
	```
      - status_id
      - author.login
      - my_new_custom_field
      - notes
    ```
- notes_filter [string]:
	- If you want issue notes on final JSON, you can specify here an **expression to match specific notes**.
	- e.g.:
	```
	"^[0-9]{2}" // just notes starting with 2 digits
    "batman$" // just notes ending with 'batman'
	```

## Tested Versions

- **Redmine version:** 3.3.2
- **Ruby version:** 2.3.3-p222
- **Rails version:** 4.2.7.1