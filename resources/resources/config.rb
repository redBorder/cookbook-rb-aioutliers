# Cookbook:: :: rbaioutliers
#
# Resource:: config
#

unified_mode true
actions :add, :remove, :register, :deregister
default_action :add

attribute :druid_broker, kind_of: String, default: 'druid-broker.service:8080'
#Deep Learning

attribute :log_file, kind_of: String, default: '/var/log/rb-aioutliers/outliers.log'
attribute :s3_host, kind_of: String, default: 's3.service'
attribute :s3_port, kind_of: Integer, default: 9000
attribute :s3_bucket, kind_of: String, default: 'mybucket'
attribute :s3_access_key, kind_of: String, default: 'mykey'
attribute :s3_secret_key, kind_of: String, default: 'mykey'
attribute :zookeeper_hosts, kind_of: String, default: 'zookeeper.service:2181'
attribute :zk_name, kind_of: String, default: "node_name"
attribute :rails_host, kind_of: String, default: 'webui.service'
attribute :rails_token, kind_of: String, default: 'token'

#Shallow
attribute :contamination, kind_of: Float, default: 0.01
attribute :sensitivity, kind_of: Float, default: 0.95
