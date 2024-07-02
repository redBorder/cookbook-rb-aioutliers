# Cookbook:: rbaioutliers
#
# Provider:: config
#

action :add do
  begin
    druid_broker = new_resource.druid_broker
    log_file = new_resource.log_file
    s3_bucket = new_resource.s3_bucket
    s3_access_key = new_resource.s3_access_key
    s3_secret_key = new_resource.s3_secret_key
    s3_host = new_resource.s3_host
    s3_port = new_resource.s3_port
    zookeeper_hosts = new_resource.zookeeper_hosts
    rails_host = new_resource.rails_host
    rails_token = new_resource.rails_token
    sensitivity = new_resource.sensitivity
    contamination = new_resource.contamination
    zk_name = new_resource.zk_name

    dnf_package 'rb-aioutliers' do
      action :upgrade
      flush_cache before: true
    end
    
    begin
      s3 = data_bag_item('passwords', 's3')
      unless s3.empty?
        s3_bucket = s3['s3_bucket']
        s3_url = s3['s3_url']
        s3_access_key = s3['s3_access_key_id']
        s3_secret_key = s3['s3_secret_key_id']
      end
    rescue => e
      Chef::Log.error("Error getting s3: #{e.message}")
    end

    begin
      node_sens = node["redborder"]["outliers"]["sensitivity"]
      sensitivity = node_sens if node_sens && !node_sens.empty?
    rescue => e
      Chef::Log.error("Could not get sensitivity value: #{e.message}")
    end

    begin
      node_cont = node["redborder"]["outliers"]["contamination"]
      contamination = node_cont if node_cont && !node_cont.empty?
    rescue => e
      Chef::Log.error("Could not get contamination value: #{e.message}")
    end

    begin
      zk_name=node["name"]
    rescue => e
      Chef::Log.error("Could not get node name value: #{e.message}")
    end

    begin
      rails_token = `echo "SELECT authentication_token FROM users WHERE id = 1;" | rb_psql redborder | awk 'NR==3 {print $1}' | tr -d '\n'`
    rescue => e
      Chef::Log.error("Could not get authentication_token")
    end

    template '/opt/rb-aioutliers/resources/src/config.ini' do
      source 'rb-aioutliers_config.ini.erb'
      owner 'rb-aioutliers'
      group 'rb-aioutliers'
      mode '644'
      retries 2
      variables(
        druid_broker: druid_broker,
        log_file: log_file,
        s3_bucket: s3_bucket,
        s3_host: s3_host,
        s3_access_key: s3_access_key,
        s3_secret_key: s3_secret_key,
        s3_port: s3_port,
        zookeeper_hosts: zookeeper_hosts,
        rails_host: rails_host,
        rails_token: rails_token,
        sensitivity: sensitivity,
        contamination: contamination,
        zk_name: zk_name
      )
      cookbook 'rbaioutliers'
      notifies :restart, 'service[rb-aioutliers]', :delayed
    end

    service 'rb-aioutliers' do
      service_name 'rb-aioutliers'
      ignore_failure true
      supports status: true, reload: true, restart: true
      action [:enable, :start]
    end

    Chef::Log.info('cookbook redborder-aioutliers has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'rb-aioutliers' do
      service_name 'rb-aioutliers'
      supports status: true, restart: true, start: true, enable: true, disable: true
      action [:disable, :stop]
    end
    Chef::Log.info('cookbook redborder-aioutliers has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['rb-aioutliers']['registered']
      query = {
        'ID' => "rb-aioutliers-#{node['hostname']}",
        'Name' => 'rb-aioutliers',
        'Address' => node['ipaddress'],
        'Port' => 443
      }
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.default['rb-aioutliers']['registered'] = true
      Chef::Log.info('rb-aioutliers service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['rb-aioutliers']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/rb-aioutliers-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.default['rb-aioutliers']['registered'] = false
      Chef::Log.info('rb-aioutliers service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
