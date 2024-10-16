# Cookbook:: rbaioutliers
#
# Provider:: config
#
action :add do
  begin
    druid_broker = new_resource.druid_broker
    log_file = new_resource.log_file
    s3_hostname = new_resource.s3_hostname

    dnf_package 'rb-aioutliers' do
      action :upgrade
      flush_cache[:before]
    end

    template '/opt/rb-aioutliers/resources/src/config.ini' do
      source 'rb-aioutliers_config.yml.erb'
      owner 'rb-aioutliers'
      group 'rb-aioutliers'
      mode '644'
      retries 2
      variables(
        druid_broker: druid_broker,
        log_file: log_file,
        s3_hostname: s3_hostname,
        s3_bucket: s3_bucket,
        s3_access_key: s3_access_key,
        s3_secret_key: s3_secret_key
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
      query = {}
      query['ID'] = "rb-aioutliers-#{node['hostname']}"
      query['Name'] = 'rb-aioutliers'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 443
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
