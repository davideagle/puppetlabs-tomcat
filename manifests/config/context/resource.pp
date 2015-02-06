# Definition: tomcat::config::context::resource
#
# Configure Resource elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $resource_ensure specifies whether you are trying to add or remove the
#   Resource element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $resource_name is the name of the Resource to be created, relative to 
#   the java:comp/env context.
# - $auth authentication type for the Resource
# - $type is the fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource
# - $closeMethod Name of the zero-argument method to call on a singleton 
#   resource when it is no longer required.
# - $description Optional, human-readable description of this resource.
# - $scope Specify whether connections obtained through this resource 
#   manager can be shared. [Shareable|Unshareable]
# - $singleton Specify whether this resource definition is for a singleton 
#   resource [true|false]
#   $type The fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource.
# - An optional hash of $additional_attributes to add to the Resource. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::context::resource (
  $resource_name         = undef,
  $auth                  = undef,
  $closeMethod           = undef,
  $description           = undef,
  $scope                 = undef,
  $singleton             = undef,
  $type                  = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $resource_ensure       = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($resource_ensure, '^(present|absent|true|false)$')
  
  if $resource_name {
    $_resource_name = $resource_name
  } else {
    $_resource_name = $name
  }

  $base_path = "Context/Resource[#attribute/name='${_resource_name}']"

  if $resource_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    
    $resource   = "set ${base_path}/#attribute/name ${_resource_name}"
    
    if $auth {
      $_auth = "set ${base_path}/#attribute/auth ${auth}"
    } else {
      $_auth = undef
    }
    
    if $closeMethod {
      $_closeMethod = "set ${base_path}/#attribute/closeMethod ${closeMethod}"
    } else {
      $_closeMethod = undef
    }
    
    if $description {
      $_description = "set ${base_path}/#attribute/description ${description}"
    } else {
      $_description = undef
    }
    
    if $scope {
      $_scope = "set ${base_path}/#attribute/scope ${scope}"
    } else {
      $_scope = undef
    }
    
    if $singleton {
      $_singleton = "set ${base_path}/#attribute/singleton ${singleton}"
    } else {
      $_singleton = undef
    }
    
    if $type {
      $_type = "set ${base_path}/#attribute/type ${type}"
    } else {
      $_type = undef
    }


    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}[#attribute/name='${resource_name}']/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}[#attribute/name='${resource_name}']/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

                                    
    $changes = delete_undef_values([$_resource, $_auth, $_closeMethod,
                                    $_description, $_scope, $_singleton, $_type, $_additional_attributes])
  }

  augeas { "context-${catalina_base}-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
