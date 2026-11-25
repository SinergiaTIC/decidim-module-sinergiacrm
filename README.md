# Decidim SinergiaCRM integration module

[![[CI] Lint](https://github.com/SinergiaTIC/decidim-module-sinergiacrm/actions/workflows/lint.yml/badge.svg)](https://github.com/SinergiaTIC/decidim-module-sinergiacrm/actions/workflows/lint.yml)
[![[CI] Test](https://github.com/SinergiaTIC/decidim-module-sinergiacrm/actions/workflows/test.yml/badge.svg)](https://github.com/SinergiaTIC/decidim-module-sinergiacrm/actions/workflows/test.yml)

This module provides certain integrations in order to use [SinergiaCRM](https://www.sinergiatic.org/sinergiacrm/) with Decidim.

## Features

- Participants can log in with their SinergiaCRM Portal account (OAuth2 authorization code flow).
- Optionally, the standard login can be replaced with a big SinergiaCRM button, keeping the email and password form available for administrators.

## Requirements

The OAuth2 integration requires a portal client in SinergiaCRM:

1. Log in to SinergiaCRM as an administrator.
2. Go to **Administration**, open **OAuth2 Clients** and choose **New Portal Client (Authorization Code)**.
3. Set the **Redirect URL** to `https://YOUR_DECIDIM_HOST/users/auth/sinergia_crm/callback`. It must match exactly.
4. For a confidential client, check **Is Confidential** and define a secret. Copy it before saving, as it cannot be recovered afterwards.
5. Save the client and use its UUID as `SINERGIA_CRM_CLIENT_ID`.

Contacts and organizations must have the portal access enabled in SinergiaCRM to be able to log in.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-sinergiacrm", git: "https://github.com/SinergiaTIC/decidim-module-sinergiacrm"
```

And then execute:

```bash
bundle
```

Depending on your Decidim version, you can choose the corresponding version to ensure compatibility:

| Version | Compatible Decidim versions |
|---------|-----------------------------|
| 0.1.x   | 0.32.x                      |

## Configuration

By default, the module is configured to read the configuration from ENV variables.

Currently, the following ENV variables are supported:

| ENV variable | Description | Default value |
| ------------ | ----------- |-------|
| SINERGIA_CRM_SITE | Base URL of the SinergiaCRM instance, as seen from the browser. Required to enable the login. | |
| SINERGIA_CRM_CLIENT_ID | UUID of the OAuth2 portal client. Required to enable the login. | |
| SINERGIA_CRM_CLIENT_SECRET | Secret of the OAuth2 portal client. Leave it empty for public (non confidential) clients. | |
| SINERGIA_CRM_AUTHORIZE_URL | **Optional**, path of the authorization endpoint. | `/index.php?entryPoint=sticPortalLogin` |
| SINERGIA_CRM_TOKEN_URL | **Optional**, path of the token endpoint. | `/index.php?entryPoint=sticPortalOAuthToken` |
| SINERGIA_CRM_ICON | **Optional**, defaults to the SinergiaCRM logo. If you want to override it, place the image under your `app/packs/images/my-icon.png` and reference it here as `media/images/my-icon.png`. | `media/images/sinergiacrm-icon.png` |
| SINERGIA_CRM_OVERRIDE_LOGIN | If true, replaces the standard login with a big SinergiaCRM button. | `false` |

The login button is only available when both `SINERGIA_CRM_SITE` and `SINERGIA_CRM_CLIENT_ID` are present.

### First login

SinergiaCRM only provides the email of the person logging in. As the name is not provided, participants are asked to complete their profile (name and nickname) and to confirm their email the first time they log in.

### Overriding the standard login

With `SINERGIA_CRM_OVERRIDE_LOGIN=true`, the login shows an introductory text and a big "Log in with SinergiaCRM" button. The email and password form is hidden behind an "Administration access" button, so administrators can still log in.

It only applies to the organizations that have the SinergiaCRM provider enabled. The texts can be changed by overriding the `decidim.sinergiacrm.login` translation keys.

Decidim caches the login buttons, so clear the cache after changing this setting:

```bash
bin/rails runner "Rails.cache.clear"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SinergiaTIC/decidim-module-sinergiacrm.

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby, Node.js and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the development app database.

Then to test how the module works in Decidim, start the development server from
the root of the module:

```bash
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bin/dev
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.org/) linter is used for the Ruby language,
[ERB Lint](https://github.com/Shopify/erb_lint) for the views, and
[ESLint](https://eslint.org/) and [Stylelint](https://stylelint.io/) for the
JavaScript and the stylesheets.

You can run the code styling checks by running the following commands from the
console:

```bash
bundle exec rubocop
bundle exec erb_lint --lint-all
npm run lint
npm run stylelint
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Visual Studio Code - [RuboCop for Visual Studio Code](https://github.com/rubocop/vscode-rubocop)

### Testing

To run the tests, run the following in the gem development path:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
