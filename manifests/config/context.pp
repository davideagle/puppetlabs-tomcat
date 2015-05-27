# Definition: tomcat::config::context
#
# Configure attributes for the Context element in $CATALINA_BASE/conf/context.xml
#
# Parameters
# - $catalina_base is the base directory for the Tomcat installation.



define tomcat::config::context (
  $catalina_base         = $::tomcat::catalina_home,
  $context_ensure        = 'present',
  $doc_base              = undef,
  $server_config         = false,
  $parent_service        = undef,
  $parent_engine         = undef,
  $parent_host           = undef,
  $watched_resource      = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($context_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)
  
  if $doc_base and ! $server_config {
    fail("doc_base can not be set in context.xml")
  }
  
  if $watched_resource {
    $_watched_resource = $watched_resource
  } else {
    $_watched_resource = 'WEB-INF/web.xml'
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
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
    } elsif $parent_host and $_parent_engine {
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${_parent_engine}']/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
    } else {
      $base_path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host/Context[#attribute/docBase='${_doc_base}']"
    }
    
  } else {
    $_file = 'context.xml'
    $base_path = "Context"
  }
  
  if $context_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $context = "set ${base_path}"
    
    $__watched_resource = "set ${base_path}/WatchedResource/#text \"${_watched_resource}\""
  
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
  
    $changes = delete_undef_values(flatten([$context, $_additional_attributes, $__watched_resource, $_attributes_to_remove]))
  }
  
  notify{"context changes ${changes}":}
  notify{"${catalina_base}-${_parent_service}-${_parent_engine}-${parent_host}-context-${name}":}
  
  if ! empty($changes) {
    augeas { "${catalina_base}-${_parent_service}-${_parent_engine}-${parent_host}-context-${name}":
    #augeas { "${catalina_base}-context-${name}":
      lens    => 'Xml.lns',
      incl    => "${catalina_base}/conf/${_file}",
      changes => $changes
    }
  }
}
