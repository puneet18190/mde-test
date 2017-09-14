# Be sure to restart your server when you modify this file.

Desy::Application.config.session_store :cookie_store, key: SETTINGS['cookie_key'], expire_after: SETTINGS['session_timeout'].hours