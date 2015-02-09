# Used for pre-suite tests
test_name "Hosts provisionning" do

  if ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
    skip_test(msg="Provisionning option is set to 'no'")
  else
    domain = "us-west-2.compute.internal"
    puppet_version = "3.5.1"
    puppet_env = ENV['BEAKER_git_branch']
    #puppet_env=`git symbolic-ref --short -q HEAD | tr -d '\n'`

    # Provisionning is based on node's role defined in hosts file
      step 'PuppetMaster Node provisionning' do
              scp_to master, "bootstrap_puppetmaster.sh", "/home/admin/bootstrap_puppetmaster.sh"
              on master, "sed -i 's/#{master}/#{master}.#{domain} #{master}/g' /etc/hosts"
              on master, "chmod +x /home/admin/bootstrap_puppetmaster.sh"
              on master, "/home/admin/bootstrap_puppetmaster.sh #{puppet_version} #{puppet_env}", :acceptable_exit_codes => [0,2]
              on master, "puppet --version"
      end

      step 'Nodes provisionning' do
            agents = hosts_as :agent
            agents.each do |agent|
              on  agent, "sed -i 's/#{agent}/#{agent}.#{domain} #{agent}/g' /etc/hosts"
              scp_to agent, "bootstrap_client.sh", "/home/admin/bootstrap_client.sh"
              on agent, "chmod +x /home/admin/bootstrap_client.sh"
              on agent, "/home/admin/bootstrap_client.sh #{puppet_version} #{puppet_env}", :acceptable_exit_codes => [0,2]
              on agent, "puppet agent -t", :acceptable_exit_codes => [0,2]
            end
      end

  end
end
