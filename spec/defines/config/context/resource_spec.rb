require 'spec_helper'

describe 'tomcat::config::context::resource', :type => :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'jdbc'
  end
  context 'Add Resource' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :resource_name         => 'jdbc',
        :auth                  => 'Container',
        :closeMethod           => 'closeMethod',
        :description           => 'description',
        :scope                 => 'Shareable',
        :singleton             => 'true',
        :type                  => 'net.sourceforge.jtds.jdbcx.JtdsDataSource',
        :additional_attributes => {'key' => 'value'}
        #  'key' => 'value',
        #}

      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resource-jdbc').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/Resource/#attribute/name jdbc',
        
        'set Context/Resource/#attribute/auth Container',
        'set Context/Resource/#attribute/closeMethod closeMethod',
        'set Context/Resource/#attribute/description description',
        'set Context/Resource/#attribute/scope Shareable',
        'set Context/Resource/#attribute/singleton true',
        'set Context/Resource/#attribute/type net.sourceforge.jtds.jdbcx.JtdsDataSource',
        'set Context/Resource/#attribute/key value',
        ]
      )
    }
  end
end