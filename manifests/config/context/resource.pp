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
# - An optional hash of $additional_attributes to add to the Resource. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::context::resource (
  $resource_name         = $name,
  $auth                  = undef,
  $type                  = undef,
  $driverClassName       = undef,
  $username              = undef,
  $password              = undef,
  $maxTotal              = undef,
  $maxIdle               = undef,
  $maxWaitMillis         = undef,
  $url                   = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $resource_ensure       = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($resource_ensure, '^(present|absent|true|false)$')

  $base_path = 'Context/Resource'

  if $resource_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_resource_name   = "set ${base_path}/#attribute/name ${resource_name}"
    $_auth            = "set ${base_path}/#attribute/auth ${auth}"
    $_type            = "set ${base_path}/#attribute/type ${type}"
    $_driverClassName =
      "set ${base_path}/#attribute/driverClassName ${driverClassName}"
    $_username        = "set ${base_path}/#attribute/username ${username}"
    $_password        = "set ${base_path}/#attribute/password ${password}"
    $_maxTotal        = "set ${base_path}/#attribute/maxActive ${maxTotal}"
    $_maxIdle         = "set ${base_path}/#attribute/maxIdle ${maxIdle}"
    $_maxWaitMillis   = "set ${base_path}/#attribute/maxWait ${maxWaitMillis}"
    $_url             = "set ${base_path}/#attribute/url ${url}"

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

    $changes = delete_undef_values([$_resource_name, $_auth, $_type,
                                    $_driverClassName, $_username, $_password,
                                    $_maxTotal, $_maxIdle, $_maxWaitMillis,
                                    $_url, $_additional_attributes, $_attributes_to_remove])
  }

  augeas { "context-${catalina_base}-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
