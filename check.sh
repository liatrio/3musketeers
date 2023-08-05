#!/usr/bin/env bash

TOOLS="alpine aws gradle java k8s terraform"

success() {
  echo "✅  ${1} validated"
}

fail() {
  echo "❌  ${1} validation failed...see output above to troubleshoot"

}

sep() {
  seq -s⎯ 79 | tr -d '[:digit:]'
  echo
}

echo "⚙️  Checking 3 Musketeers setup..."
sep

for tool in ${TOOLS}; do
  echo "⏳  Checking ${tool}..."
  make "${tool}" && success "${tool}" || fail "${tool}"
  sep
done
