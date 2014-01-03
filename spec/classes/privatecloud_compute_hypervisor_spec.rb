#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for privatecloud::compute::hypervisor class
#

require 'spec_helper'

describe 'privatecloud::compute::hypervisor' do

  shared_examples_for 'openstack compute hypervisor' do

    let :pre_condition do
      "class { 'privatecloud::compute':
        nova_db_host            => '10.0.0.1',
        nova_db_user            => 'nova',
        nova_db_password        => 'secrete',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        ks_glance_internal_host => '10.0.0.1',
        glance_port             => '9292',
        verbose                 => true,
        debug                   => true }"
    end

    let :params do
      { :libvirt_type                         => 'kvm',
        :api_eth                              => '10.0.0.1',
        :ks_nova_internal_proto               => 'http',
        :ks_nova_internal_host                => '10.0.0.1' }
    end

    it 'configure nova-compute' do
      should contain_class('nova::compute').with(
          :enabled          => true,
          :vnc_enabled      => false,
          :virtio_nic       => false,
          :neutron_enabled  => true
        )
    end

    it 'configure libvirt driver' do
      should contain_class('nova::compute::libvirt').with(
          :libvirt_type      => 'kvm',
          :vncserver_listen  => '0.0.0.0',
          :migration_support => true,
        )
    end

    it 'configure nova spice agent' do
      should contain_class('nova::compute::spice').with(
          :agent_enabled              => true,
          :server_listen              => '0.0.0.0',
          :server_proxyclient_address => '10.0.0.1',
          :proxy_protocol             => 'http',
          :proxy_host                 => '10.0.0.1'
        )
    end

    it 'configure nova compute with neutron' do
      should contain_class('nova::compute::neutron')
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute hypervisor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack compute hypervisor'
  end

end
