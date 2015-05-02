#!/bin/bash

set -xe

GOPATH=/workspace/services-api-ci/upgrade-pipeline
WORKSPACE_DIR="$(cd $(dirname ${BASH_SOURCE[0]})/../../ && pwd)"
RELENG_ENV=${RELENG_ENV:-wasabi}
APPS_DOMAIN=${RELENG_ENV}-app

if [ "$RELENG_ENV" == "bosh-lite" ]
then
  API_URL="api.10.244.0.34.xip.io"
  APPS_URL="10.244.0.34.xip.io"
  CF_ADMIN_PASSWORD=admin
else
  API_URL="api.${RELENG_ENV}.cf-app.com"
  APPS_URL="$APPS_DOMAIN.cf-app.com"
fi

go get github.com/onsi/ginkgo/ginkgo
go install github.com/onsi/ginkgo/ginkgo

export PATH=$PATH:$GOPATH/bin

cd $WORKSPACE_DIR/services-api-ci/upgrade-pipeline/src/upgrade_test/

cat > integration_config.json <<EOF
{
  "api": "$API_URL",
  "admin_user": "admin",
  "admin_password": "${CF_ADMIN_PASSWORD}",
  "apps_domain": "${APPS_URL}",
  "skip_ssl_validation": true
}
EOF

GOPATH=$GOPATH:$GOPATH/src/github.com/cloudfoundry/cf-acceptance-tests/Godeps/_workspace/ \
CONFIG=`pwd`/integration_config.json \
ginkgo after_upgrade/
