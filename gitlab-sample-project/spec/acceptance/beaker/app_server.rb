# Test used to validate front server role.
test_name "App Server Role" do

# Return true if app_server role is found
  app_server_role = any_hosts_as?(:app_server)

  if app_server_role == false
    skip_test(msg="This test is not applicable because no role app_server was found in hosts file")
  else
    app_server_hosts = hosts_as :app_server
    app_server_hosts.each do |app_server|

    # Commands to execute on the target system.
    apache_status="service apache2 status"

    # Output result expected
    state_expected="running"

    # Checking services status
    on(app_server, apache_status) { assert_match(state_expected, stdout, 'Not the state expected for apache service') }
    end
  end
end
