module Fog
  module Sql
    class AzureRM
      # Real class for Sql Server Request
      class Real
        def list_sql_servers(resource_group)
          msg = "Listing Sql Servers in Resource Group: #{resource_group}."
          Fog::Logger.debug msg
          resource_url = "#{resource_manager_endpoint_url}/subscriptions/#{@subscription_id}/resourceGroups/#{resource_group}/providers/Microsoft.Sql/servers?api-version=#{REST_CLIENT_API_VERSION[0]}"
          begin
            token = Fog::Credentials::AzureRM.get_token(@tenant_id, @client_id, @client_secret)
            response = RestClient.get(
              resource_url,
              accept: :json,
              content_type: :json,
              authorization: token
            )
          rescue RestClient::Exception => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "Sql Servers listed successfully in Resource Group: #{resource_group}"
          Fog::JSON.decode(response)['value']
        end
      end

      # Mock class for Sql Server Request
      class Mock
        def list_sql_servers(*)
          [
            {
              'location' => '{server-location}',
              'properties' => {
                'version' => '{server-version}',
                'administratorLogin' => '{admin-name}',
                'administratorLoginPassword' => '{admin-password}'
              }
            },
            {
              'location' => '{server-location}',
              'properties' => {
                'version' => '{server-version}',
                'administratorLogin' => '{admin-name}',
                'administratorLoginPassword' => '{admin-password}'
              }
            }
          ]
        end
      end
    end
  end
end
