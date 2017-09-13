require 'open-uri'

execute 'cd /tmp && wget "https://ja.wordpress.org/latest-ja.zip" && unzip latest-ja.zip'

node[:sites].each do |site|
  dir = "#{node[:wordpress][:directory]}/#{site[:domain]}"

  execute 'mv wordpress to domain directory' do
    command "sudo cp -r /tmp/wordpress #{dir} && sudo chown -R nginx:nginx #{dir}"
    not_if "test -d #{dir}"
  end

  keys = []
  open ("https://api.wordpress.org/secret-key/1.1/salt/") { |io| keys << io.read }

  template "#{dir}/wp-config.php" do
    source 'templates/wp-config.php.erb'
     variables ({
       db_name: node[:db][:name],
       db_user: node[:db][:user],
       db_password: node[:db][:password],
       table_prefix: site[:table_prefix],
       secret_keys: keys.join("\n")
     })
     mode '644'
     owner 'root'
     group 'root'

     not_if "test -e #{dir}/wp-config.php"
   end
end

execute 'rm -rf /tmp/wordpress'
execute 'rm -rf /tmp/latest-ja.zip'
