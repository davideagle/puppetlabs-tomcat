require 'spec_helper'

describe 'tomcat::config::context', :type => :define do
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
    'Context'
  end
  context 'Set Context Default Wathced resource' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :additional_attributes => {
          'path' => '/myapp',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-context-Context').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context',
        'set Context/#attribute/path \'/myapp\'',
        'set Context/WatchedResource/#text "WEB-INF/web.xml"',
        'rm Context/#attribute/foobar',
      ]
    )
    }
  end
  
  context 'Set Context Wathced resource' do
    let :params do
      {
        :catalina_base    => '/opt/apache-tomcat/test',
        :watched_resource => 'res.xml',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-context-Context').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context',
        'set Context/WatchedResource/#text "res.xml"',
      ]
    )
    }
  end
  
  context 'Context in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
        :doc_base              => 'myapp.war',
        :watched_resource      => 'res.xml',
        :additional_attributes => {
          'path' => '/myapp',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina-localhost-context-Context').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/path \'/myapp\'',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/WatchedResource/#text "res.xml"',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/foobar',                                                                                                                       
      ]
    )
    }
  end
  
  context 'No doc_base in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :context_ensure        => 'present',
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
        :watched_resource      => 'res.xml',
        :additional_attributes => {
          'path' => '/test',
        },
        :attributes_to_remove  => [
        'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina-localhost-context-Context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'Context\']',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'Context\']/#attribute/path \'/test\'',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'Context\']/WatchedResource/#text "res.xml"',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'Context\']/#attribute/foobar',
       ]
    )
    }
  end
  
  context 'context with $parent_service in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_service        => 'test',
        :watched_resource      => 'res.xml',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-test---context-Context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
      'set Server/Service[#attribute/name=\'test\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']',
      'set Server/Service[#attribute/name=\'test\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']/WatchedResource/#text "res.xml"',
       ]
    )
    }
  end
  
    
  context 'context with $parent_host in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_host           => 'localhost',
        :watched_resource      => 'res.xml',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina--localhost-context-Context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/WatchedResource/#text "res.xml"',
       ]
    )
    }
  end
  
  context '$parent_engine, no $parent_host in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_engine         => 'Catalina',
        :watched_resource      => 'res.xml',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina---context-Context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']/WatchedResource/#text "res.xml"',
      ]
    )
    }
  end
  
  context 'Remove Context in Server.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => true,
        :context_ensure        => 'absent',
        :doc_base              => 'myapp.war',
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina-localhost-context-Context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
       'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']',
      ]
    )
    }
  end
  
    context 'Remove Context in Contex.xml' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :server_config         => false,
        :context_ensure        => 'absent',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-context').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
       'rm Context',
      ]
    )
    }
  end
  
  describe 'failing tests' do
    context 'docBase can not exist in context.xml' do
      let :params do
        {
          :docBase      => 'foo',
          server_config => false,
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /doc_base can not be set in context.xml/)
      end
    end
    context 'bad context_ensure' do
      let :params do
        {
          :context_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'Bad additional_attributes' do
      let :params do
        {
          :additional_attributes => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'Bad attributes_to_remove' do
      let :params do
        {
          :attributes_to_remove => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /is not an Array/)
      end
    end
    context 'old augeas' do
      let :facts do
        {
          :osfamily      => 'Debian',
          :augeasversion => '0.10.0'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /configurations require Augeas/)
      end
    end
  end
end

