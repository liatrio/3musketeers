#!/usr/bin/env bash

# These tests should have a 0 return code
TESTS=(alias debug help version "k8s kubectl version --client" "aws --version" "terraform version" "node npm --version")

# These tests should have non-zero return code
NEG_TESTS=(plugin "k8s kubectl version")

success() {
  echo "✅  ${1} pass"
}

fail() {
  echo "❌  ${1} fail...see output above to troubleshoot"

}

sep() {
  seq -s⎯ 79 | tr -d '[:digit:]'
  echo
}

echo "⚙️  Testing 3m8s commands..."
sep

for test in "${TESTS[@]}"; do
  echo "⏳  Testing ${test}..."
  # TODO fail test if there's not output
  make -- ${test} && success "${test}" || fail "${test}"
  sep
done

for test in "${NEG_TESTS[@]}"; do
  echo "⏳  Testing ${test}..."
  make -- ${test} && fail "${test}" || success "${test}"
  sep
done

test="create plugin"
make plugin testing && success "${test}" || fail "${test}"
test="create plugin when Makefile exists"
rm 3m8s.d/testing.mk
make plugin testing && fail "${test}" || success "${test}"
test="create plugin when Compose file exists"
rm 3m8s.d/testing.yaml
make plugin testing && fail "${test}" || success "${test}"
rm 3m8s.d/testing.*

test="runs even if 3m8s.d is missing"
mv 3m8s.d 3m8s.d.orig
make && success "${test}" || fail "${test}"
test="creates 3m8s.d if missing"
[ -d 3m8s.d ] && success "${test}" || fail "${test}"
rmdir 3m8s.d
mv 3m8s.d.orig 3m8s.d
