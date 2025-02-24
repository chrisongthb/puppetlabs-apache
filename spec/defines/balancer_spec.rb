# frozen_string_literal: true

require 'spec_helper'

describe 'apache::balancer', type: :define do
  let :title do
    'myapp'
  end

  include_examples 'Debian 11'

  describe 'apache pre_condition with defaults' do
    let :pre_condition do
      'include apache'
    end

    describe 'works when only declaring resource title' do
      it { is_expected.to contain_concat('apache_balancer_myapp') }
      it { is_expected.to contain_concat__fragment('00-myapp-header').with_content(%r{^<Proxy balancer://myapp>$}) }
    end
    describe 'accept a target parameter and use it' do
      let :params do
        {
          target: '/tmp/myapp.conf',
        }
      end

      it {
        is_expected.to contain_concat('apache_balancer_myapp').with(path: '/tmp/myapp.conf')
      }
    end
    describe 'accept an options parameter and use it' do
      let :params do
        {
          options: ['timeout=0', 'nonce=none'],
        }
      end

      it {
        is_expected.to contain_concat__fragment('00-myapp-header').with_content(
          %r{^<Proxy balancer://myapp timeout=0 nonce=none>$},
        )
      }
    end
  end
  describe 'apache pre_condition with conf_dir set' do
    let :pre_condition do
      'class{"apache":
          confd_dir => "/junk/path"
       }'
    end

    it {
      is_expected.to contain_concat('apache_balancer_myapp').with(path: '/junk/path/balancer_myapp.conf')
    }
  end

  describe 'with lbmethod set' do
    let :params do
      {
        proxy_set: {
          'lbmethod' => 'bytraffic',
        },
      }
    end

    it { is_expected.to contain_apache__mod('slotmem_shm') }
    it { is_expected.to contain_apache__mod('lbmethod_bytraffic') }
  end
end
