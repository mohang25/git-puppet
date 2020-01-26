INSTALL_DIR="/opt/puppetlabs/server/apps/puppetserver"

JRUBY_JAR="${JRUBY_JAR:-${INSTALL_DIR}/jruby-1_7.jar}"

if [ ! -e "$JRUBY_JAR" ]; then
  echo "Unable to find specified JRUBY_JAR: ${JRUBY_JAR}" 1>&2
  return 1
fi

CLASSPATH="${CLASSPATH}:${JRUBY_JAR}:/opt/puppetlabs/server/data/puppetserver/jars/*"
