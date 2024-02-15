#!/usr/bin/env bash

nfcore_ver="$(poetry show nf-core | sed -n 's/\s*version\s\+:\s\+\([0-9.]\+\).*/\1/p')"
echo "version : $nfcore_ver"

wget -O /workspaces/nf-scil/.editorconfig \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.editorconfig

wget -O /workspaces/nf-scil/.prettierignore \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.prettierignore

echo ".github" >> /workspaces/nf-scil/.prettierignore
echo ".devcontainer" >> /workspaces/nf-scil/.prettierignore
echo ".vscode" >> /workspaces/nf-scil/.prettierignore
echo "venv" >> /workspaces/nf-scil/.prettierignore
echo ".venv" >> /workspaces/nf-scil/.prettierignore
echo ".test_data" >> /workspaces/nf-scil/.prettierignore
echo ".pytest_cache" >> /workspaces/nf-scil/.prettierignore

wget -O /workspaces/nf-scil/.prettierrc.yml \
    https://github.com/nf-core/tools/raw/$nfcore_ver/.prettierrc.yml

wget -O /workspaces/nf-scil/pytest.ini \
    https://github.com/nf-core/tools/raw/$nfcore_ver/pytest.ini

wget -O /workspaces/nf-scil/requirements.txt \
    https://github.com/nf-core/tools/raw/$nfcore_ver/requirements.txt

wget -O /workspaces/nf-scil/.requirements.nf-core.new \
    https://github.com/nf-core/tools/raw/$nfcore_ver/requirements-dev.txt

touch .requirements.nf-core
cat .requirements.nf-core | xargs poetry remove
cat .requirements.nf-core.new | xargs poetry add
mv .requirements.nf-core.new .requirements.nf-core
poetry lock
