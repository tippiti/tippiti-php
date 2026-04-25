#!/usr/bin/env bash
set -euo pipefail

SPEC_URL="${TIPPITI_OPENAPI_URL:-https://apidocs.tippiti.io/api.json}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${ROOT_DIR}/src/Generated"

cd "${ROOT_DIR}"

if ! command -v npx >/dev/null 2>&1; then
    echo "npx (Node.js) is required to run openapi-generator-cli." >&2
    exit 1
fi

TMP_OUTPUT="$(mktemp -d)"
trap 'rm -rf "${TMP_OUTPUT}"' EXIT

npx --yes @openapitools/openapi-generator-cli generate \
    -i "${SPEC_URL}" \
    -g php \
    -o "${TMP_OUTPUT}" \
    -c "${ROOT_DIR}/scripts/openapi-generator.yaml"

if [[ ! -d "${TMP_OUTPUT}/Api" || ! -d "${TMP_OUTPUT}/Model" ]]; then
    echo "Generator output is missing Api/ or Model/ — aborting before wiping ${TARGET_DIR}." >&2
    exit 1
fi

shopt -s nullglob
ROOT_PHP_FILES=("${TMP_OUTPUT}"/*.php)
shopt -u nullglob

if [[ ${#ROOT_PHP_FILES[@]} -eq 0 ]]; then
    echo "Generator output is missing root PHP files (Configuration, ApiException, ...) — aborting." >&2
    exit 1
fi

rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

cp -R "${TMP_OUTPUT}/Api" "${TARGET_DIR}/"
cp -R "${TMP_OUTPUT}/Model" "${TARGET_DIR}/"
cp "${ROOT_PHP_FILES[@]}" "${TARGET_DIR}/"

echo "Regenerated ${TARGET_DIR} from ${SPEC_URL}"
