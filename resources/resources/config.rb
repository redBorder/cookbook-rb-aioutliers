# Cookbook:: :: rbaioutliers
#
# Resource:: config
#

unified_mode true
actions :add, :remove, :register, :deregister
default_action :add

attribute :druid_broker, kind_of: String, default: 'druid-broker.service:8082'
attribute :log_file, kind_of: String, default: '/var/log/rb-aioutliers/outliers.log'
attribute :s3_hostname, kind_of: String, default: 's3.service:9000'
attribute :s3_secrets, kind_of: Hash, default: {}
# true: S3 keys are OpenBao placeholders; configs are rendered by the agent into /run
attribute :openbao, kind_of: [TrueClass, FalseClass], default: false
