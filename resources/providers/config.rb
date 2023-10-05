# Cookbook Name:: rbaioutliers
#
# Provider:: config
#
action :add do
  begin
    dnf_package "rb-aioutliers" do
      action :upgrade
      flush_cache[:before]
    end
    template "/opt/rb-aioutliers/resources/src/config.ini" do
      source "rb-aioutliers_config.yml.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      cookbook "rbaioutliers"
      notifies :restart, "service[rb-aioutliers]", :delayed
  end

  service "rb-aioutliers" do
      service_name "rb-aioutliers"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true
      action [:enable, :start]
  end

    Chef::Log.info("cookbook redborder-aioutliers has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service "rb-aioutliers" do
      service_name "rb-aioutliers"
      supports :status => true, :restart => true, :start => true, :enable => true, :disable => true
      action [:disable, :stop]
    end
    Chef::Log.info("cookbook redborder-aioutliers has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
