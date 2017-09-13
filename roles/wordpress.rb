# frozen_string_literal: true

node.reverse_merge!(YAML.load_file("#{File.dirname(__FILE__)}/../nodes/default.yml"))
local_hash = YAML.load_file("#{File.dirname(__FILE__)}/../nodes/local.yml")
node.reverse_merge!(local_hash)
nginx_hash = YAML.load_file("#{File.dirname(__FILE__)}/../nodes/nginx_build.yml")
node.reverse_merge!(nginx_hash)

include_recipe '../cookbooks/nginx/default.rb'
include_recipe '../cookbooks/php/default.rb'
include_recipe '../cookbooks/mysql/default.rb'
include_recipe '../cookbooks/wordpress/default.rb'
