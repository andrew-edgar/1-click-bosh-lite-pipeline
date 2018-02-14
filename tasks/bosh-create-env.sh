#!/bin/bash -ex

# Hack to work around Concourse, which tries to interpret ((variables)).
# Simply "unescaping" `_(_(` to `((`: 
echo "$MANIFEST" | sed -e 's/_(_(/((/g' > /tmp/bosh.yml

commit_if_changed=$(readlink -f 1-click/tasks/commit-if-changed.sh)

mkdir -p state/environments/softlayer/director/$BOSH_LITE_NAME
pushd state/environments/softlayer/director/$BOSH_LITE_NAME
    bosh2 create-env \
        --state state.json \
        --vars-store=vars.yml \
        /tmp/bosh.yml \
        -v director_vm_prefix=$BOSH_LITE_NAME

    tail -n1 /etc/hosts > hosts

    bosh2 interpolate vars.yml --path /jumpbox_ssh/private_key > jumpbox.key
    chmod 600 jumpbox.key

    git add state.json vars.yml hosts jumpbox.key
    $commit_if_changed "Update state for environments/softlayer/director/$BOSH_LITE_NAME"
popd

cp -a state/. out-state
