RPM_FILE = 'mysql57-community-release-el6-7.noarch.rpm'
WGET_RPM = "wget https://dev.mysql.com/get/#{RPM_FILE}"
TMP_DIR = '/tmp'
RPM_INSTALLED_CHECK_COMMAND = 'rpm -aq | grep mysql57-community-release-el6-7.noarch'

unless run_command(RPM_INSTALLED_CHECK_COMMAND, error: false).exit_status == 0
  execute WGET_RPM do
    cwd TMP_DIR
  end

  execute "rpm -ivh #{RPM_FILE}" do
    cwd TMP_DIR
  end
end

execute 'yum-config-manager --disable mysql57-community'
execute 'yum-config-manager --enable mysql56-community'

package 'mysql-community-server'
package 'mysql-community-devel'

remote_file '/etc/my.cnf' do
  owner 'root'
  group 'root'
  mode '0644'
end

service 'mysqld' do
  action [:enable, :start]
end

execute "mysql -uroot -e \"CREATE DATABASE IF NOT EXISTS #{node[:db][:name]} character set utf8\""
execute "mysql -uroot -e \"GRANT ALL ON \\`#{node[:db][:name]}\\`.* to '#{node[:db][:user]}'@'localhost' identified by '#{node[:db][:password]}'\""
