#!/usr/bin/env bash

nfcore_ver="$(poetry show nf-core | sed -n 's/\s*version\s\+:\s\+\([0-9.]\+\).*/\1/p')"
echo "version : $nfcore_ver"

wget -O /workspaces/nf-scil/.pre-commit-config.yaml \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.pre-commit-config.yaml

wget -O /workspaces/nf-scil/.editorconfig \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.editorconfig

wget -O /workspaces/nf-scil/.prettierignore \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.prettierignore

wget -O /workspaces/nf-scil/.prettierrc.yml \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.prettierrc.yml

wget -O /workspaces/nf-scil/pytest.ini \
    https://github.com/nf-core/tools/raw/$nfcore_ver/pytest.ini

wget -O /workspaces/nf-scil/.requirements.nf-core.new \
    https://github.com/nf-core/tools/raw/$nfcore_ver/requirements-dev.txt

touch .requirements.nf-core
cat .requirements.nf-core | xargs poetry remove
cat .requirements.nf-core.new | xargs poetry add
mv .requirements.nf-core.new .requirements.nf-core
poetry lock

pre-commit install --install-hooks
