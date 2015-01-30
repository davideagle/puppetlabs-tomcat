# Definition: tomcat::config::server::connector
#
# Configure Connector elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $connector_ensure specifies whether you are trying to add or remove the
#   Connector element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - The $port attribute. This attribute is required unless $connector_ensure
#   is set to false.
# - The $protocol attribute. Defaults to $name when not specified.
# - $parent_service is the Service element this Connector should be nested
#   beneath. Defaults to 'Catalina'.
# - An optional hash of $additional_attributes to add to the Connector. Should
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
  $additional_attributes = {}
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

    $changes = delete_undef_values([$_resource_name, $_auth, $_type,
                                    $_driverClassName, $_username, $_password,
                                    $_maxTotal, $_maxIdle, $_maxWaitMillis,
                                    $_url, $_additional_attributes ])
  }

  augeas { "context-${catalina_base}-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
