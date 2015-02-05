require 'spec_helper'

describe 'tomcat::config::context::resourcelink', :type => :define do
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
    'linkToGlobalResource'
  end
  context 'Add ResourceLink' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :global                => 'simpleValue',
        :resource_type         => 'java',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resourcelink-linkToGlobalResource').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/name linkToGlobalResource',
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/global simpleValue',
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/type java',
        ]
      )
    }
  end
end