# Specify the full base URL of the FIDC service.
host="https://your-tenant.forgeblocks.com"

# Specify the log API key and secret
api_key_id="aaa2...219"
api_key_secret="56ce...1ada1"

# Available sources are listed below. Uncomment the source you want to use. For development and debugging use "am-core" and "idm-core" respectively:
# source="am-access"
# source="am-activity"
# source="am-authentication"
# source="am-config"
source="am-core"
# source="am-everything"
# source="ctsstore"
# source="ctsstore-access"
# source="ctsstore-config-audit"
# source="ctsstore-upgrade"
# source="idm-access"
# source="idm-activity"
# source="idm-authentication"
# source="idm-config"
# source="idm-core"
# source="idm-everything"
# source="idm-sync"
# source="userstore"
# source="userstore-access"
# source="userstore-config-audit"
# source="userstore-ldif-importer"
# source="userstore-upgrade"

require 'pp'
require 'json'

prc=""
while(true) do
  o=`curl -s --get --header 'x-api-key: #{api_key_id}' #{prc} --header 'x-api-secret: #{api_key_secret}' --data 'source=#{source}' "#{host}/monitoring/logs/tail"`
  obj=JSON.parse(o)
  obj["result"].each{|r|
    pp r["payload"]
  }
  prc="--data '_pagedResultsCookie=#{obj["pagedResultsCookie"]}'"
  sleep 10
end