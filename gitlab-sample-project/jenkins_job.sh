#!/bin/bash

# Constants and Arrays
regex_use_case="featureUseCase"
branch_name=$1
data_profile=()
data_role=()
base_path="sitemodules/d2si/manifests"

echo "============== Checking modifications============"

# Check if hieradata were changed
for tier in hieradata/*; do
  if [[ -d ${tier} ]]; then
    hieradata_modified=$(git show --pretty="format:" --name-only -- "${tier}/roles")

    if [[ -z ${hieradata_modified} ]]; then
      echo "No hieradata were changed in ${tier}"
    else
      # String format to have role name
      role=$(echo ${hieradata_modified} | xargs -n 1 basename | cut -d "." -f 1)
      echo ${role} "has changed in ${tier}"

      #Check if role is already in array
      if [[ ${data_role[*]} != ${role} ]]; then
        data_role+=(${role})
      fi
    fi
  fi
done

# Check if profiles were changed
profile_modified=$(git show --pretty="format:" --name-only -- "${base_path}/profile")

if [[ -z ${profile_modified} ]]; then
  echo "No profiles were changed"
else
  # Save profiles in array
  data_profile+=(${profile_modified})

  for profile in ${data_profile[@]}; do

    # String format to have profile name
    profile=$(echo ${profile} | xargs -n 1 basename | cut -d "." -f 1)
    echo "Profile:" ${profile} "has changed"

    # Get all roles whose profile has changed
    role=$(grep -r -l -E "profile::${profile}$" "${base_path}/role")

    if [[ -z ${role} ]]; then
      echo "No role was found for ${profile} profile"
    else
      role=$(echo ${role} | xargs -n 1 basename | cut -d "." -f 1)
      echo "Role:" ${role} "has changed"

      #Check if role is already in array
      if [[ ${data_role[*]} != ${role} ]]; then
        data_role+=(${role})
      fi
    fi
  done
fi

echo "================================================="

if [[ -z ${profile_modified} ]] && [[ -z ${hieradata_modified} ]] ; then
  echo "No profiles/hieradata were changed"
else
  #Get dependencies
  bundle install

  # Check if current branch is a use case
  use_case=$(echo ${branch_name} | grep -E '${regex_use_case}')

  if [[ ${use_case} ]]; then
    # Get the use case name
    use_case_name=$(echo ${branch_name} | sed "s/^${regex_use_case}//gI")
    echo "Testing" ${use_case_name} "use case"
    BEAKER_git_branch=${branch_name} BEAKER_validate=no BEAKER_setfile=spec/acceptance/nodesets/${use_case_name}.cfg rake beaker:test;
  else
    echo "============== Testing with roles ==============="
    for role in ${data_role[@]}; do
      echo $role
    done
    echo "================================================="

    # Roles testing
    for role in ${data_role[@]}; do
      echo "Testing" $role "role"
      BEAKER_PROJECT=beaker_aws BEAKER_DEPARTMENT=DEV BEAKER_BUILD_URL=http://myjenkins:8080/job/puppet-beaker BEAKER_CREATED_BY=jenkins BEAKER_git_branch=${branch_name} BEAKER_test_file=${role}.rb BEAKER_validate=no BEAKER_setfile=spec/acceptance/nodesets/${role}.cfg rake beaker:test;
    done
  fi
fi
