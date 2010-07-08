# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_abc_session',
  :secret      => '1a20db3aabb44390956cc6e6d1f33ca8069b9b6734691cc17fac67aaa369bff453c8d759e4ba37d348ca849c6a39f8f60355535f0cf73c398ee9a206c18a928d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
