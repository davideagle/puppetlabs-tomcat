# Definition: tomcat::config::server::resourcelink
#
# Configure ResourceLink elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $server_config whether to use server.xml or context.xml to store
#   config for resources. Defaults to false (use context.xml). valid
#   values true, false
# - $ensure specifies whether you are trying to add or remove the
#   ResourceLink element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $global The name of the linked global resource in the global JNDI context.
# - $resource_type The fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource link.
# - $resource_link_name The name of the resource link to be created, relative 
#   to the java:comp/env context.
# - An optional hash of $additional_attributes to add to the Connector. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
# - $doc_base [only aplicable if $server_config = true] The Document Base 
#   (also known as the Context Root) directory for this web application, or 
#   the pathname to the web application archive file
# - $parent_service [only aplicable if $server_config = true] parent service in
#   server.xml
# - $parent_host [only aplicable if $server_config = true] parent host in 
#   server.xml
# - $parent_engine [only aplicable if $server_config = true] parent engine in
#   server.xml
define tomcat::config::context::resourcelink (
  $resource_link_name    = undef,
  $server_config         = false,
  $global                = undef,
  $resource_type         = undef,
  $doc_base              = undef,
  $parent_service        = undef,
  $parent_host           = undef,
  $parent_engine         = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $ensure                = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  
  if $resource_link_name {
    $_resource_link_name = $resource_link_name
  } else {
    $_resource_link_name = $name
  }
  
  if $server_config {
    
    $_file = 'server.xml'
    
    if $doc_base {
      $_doc_base = $doc_base
    } else {
      $_doc_base = $name
    }
  
    if $parent_service {
      $_parent_service = $parent_service
    } else {
      $_parent_service = 'Catalina'
    }
  
    if $parent_engine and ! $parent_host {
      warning('context elements cannot be nested directly under engine elements, ignoring $parent_engine')
    }
  
    if $parent_engine and $parent_host {
      $_parent_engine = $parent_engine
    } else {
      $_parent_engine = undef
    }
    
    if $parent_host and ! $_parent_engine {
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']/ResourceLink[#attribute/name='${_resource_link_name}']"
    } elsif $parent_host and $_parent_engine {
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${_parent_engine}']/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']/ResourceLink[#attribute/name='${_resource_link_name}']"
    } else {
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host/Context[#attribute/docBase='${_doc_base}']/ResourceLink[#attribute/name='${_resource_link_name}']"
    }
    
  } else {
    $_file = 'context.xml'
    $base_path = "Context/ResourceLink[#attribute/name='${_resource_link_name}']"
  }
  
  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    
    $_resource_link = "set ${base_path}/#attribute/name ${_resource_link_name}"
    
    if $global {
      $_global = "set ${base_path}/#attribute/global ${global}"
    } else {
      $_global = undef
    }
    
    if $resource_type {
      $_resource_type = "set ${base_path}/#attribute/type ${resource_type}"
    } else {
      $_resource_type = undef
    }

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([$_resource_link, $_resource_type,
                                            $_global, $_additional_attributes,
                                            $_attributes_to_remove]))
  }

  augeas { "context-${catalina_base}-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/${_file}",
    changes => $changes,
  }
}
