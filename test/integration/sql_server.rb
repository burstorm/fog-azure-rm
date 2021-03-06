require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

resources = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

azure_sql_service = Fog::Sql::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = resources.resource_groups.create(
    name: 'TestRG-SQL',
    location: LOCATION
  )

  ########################################################################################################################
  ######################                         Create Sql Server                                  ######################
  ########################################################################################################################

  server_name = rand(0...999_99)

  sql_server = azure_sql_service.sql_servers.create(
    name: server_name,
    resource_group: 'TestRG-SQL',
    location: LOCATION,
    version: '2.0',
    administrator_login: 'testserveradmin',
    administrator_login_password: 'db@admin=123'
  )
  puts "Created sql server: #{sql_server.name}"

  ########################################################################################################################
  ######################                        Create Sql Database                                 ######################
  ########################################################################################################################
  database_name = rand(0...999_99)

  sql_database = azure_sql_service.sql_databases.create(
    resource_group: 'TestRG-SQL',
    location: LOCATION,
    server_name: server_name,
    name: database_name
  )
  puts "Created sql database: #{sql_database.name}"

  ########################################################################################################################
  ######################                   Get Sql Database                                         ######################
  ########################################################################################################################

  sleep 60
  database = azure_sql_service.sql_databases.get('TestRG-SQL', server_name, database_name)
  puts "Get sql database: #{database.name}"

  ########################################################################################################################
  ######################                        List Sql Database                                   ######################
  ########################################################################################################################

  databases = azure_sql_service.sql_databases(resource_group: 'TestRG-SQL', server_name: server_name)
  puts 'List databases:'
  databases.each do |a_database|
    puts a_database.name
  end

  ########################################################################################################################
  ######################                   Destroy Sql Database                             ######################
  ########################################################################################################################

  database.destroy

  ########################################################################################################################
  ######################                        Create Sql Firewall Rule                            ######################
  ########################################################################################################################

  firewall_rule = azure_sql_service.firewall_rules.create(
    resource_group: 'TestRG-SQL',
    server_name: server_name,
    name: 'test-rule-name',
    start_ip: '10.10.10.10',
    end_ip: '10.10.10.11'
  )
  puts "Created firewall rule: #{firewall_rule.name}"

  ########################################################################################################################
  ######################                   Get Sql Firewall Rule                                    ######################
  ########################################################################################################################

  firewall_rule = azure_sql_service.firewall_rules.get('TestRG-SQL', server_name, 'test-rule-name')
  puts "Get Firewall Rule: #{firewall_rule.name}"

  ########################################################################################################################
  ######################                        List Sql Firewall Rules                             ######################
  ########################################################################################################################

  firewall_rules = azure_sql_service.firewall_rules(resource_group: 'TestRG-SQL', server_name: server_name, name: 'test-rule-name')
  puts 'List firewall rules:'
  firewall_rules.each do |a_firewall_rule|
    puts a_firewall_rule.name
  end

  ########################################################################################################################
  ######################                   Destroy Sql Firewall Rule                        ######################
  ########################################################################################################################

  firewall_rule.destroy

  ########################################################################################################################
  ######################                       Get Sql Server                                       ######################
  ########################################################################################################################

  sql_server = azure_sql_service.sql_servers.get('TestRG-SQL', server_name)
  puts "Get sql server: #{sql_server.name}"

  ########################################################################################################################
  ######################                             List Sql Servers                               ######################
  ########################################################################################################################

  servers = azure_sql_service.sql_servers(resource_group: 'TestRG-SQL')
  puts 'List sql servers:'
  servers.each do |a_server|
    puts a_server.name
  end

  ########################################################################################################################
  ######################                    Destroy Sql Servers                             ######################
  ########################################################################################################################

  sql_server.destroy

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################
  resource_group = resources.resource_groups.get('TestRG-SQL')
  resource_group.destroy
rescue
  puts 'Integration Test for sql server is failing'
  resource_group.destroy unless resource_group.nil?
end
