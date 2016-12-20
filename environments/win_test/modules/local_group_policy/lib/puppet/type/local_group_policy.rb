Puppet::Type.newtype(:local_group_policy) do
  #confine :operatingsystem => { :windows }
  desc 'Pupet type that models the local group policy editor'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Local Group Setting Name. What you see it the GUI.'
  end

  newproperty(:policy_settings) do
    desc 'Local Security Group Policy Setting. This is an array of values'
  end
end
