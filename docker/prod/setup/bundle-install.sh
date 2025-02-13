#!/bin/bash

set -e

# temporary 'seed' for working ppc64 cached vendor/bundle
if [ ! -d vendor/bundle ] && [ -n "$(uname -a | grep ppc64)" ]; then
  wget https://openproject-public.s3.eu-central-1.amazonaws.com/ruby/bundle/openproject-release-15.2-836aec00b1-vendor-bundle.tar.gz
  tar -xf openproject-release-15.2-836aec00b1-vendor-bundle.tar.gz
fi

bundle config set --local path 'vendor/bundle'
bundle config set --local without 'test development'
bundle install --jobs=8 --retry=3
bundle config set deployment 'true'
cp Gemfile.lock Gemfile.lock.bak
rm -rf vendor/bundle/ruby/*/cache
rm -rf vendor/bundle/ruby/*/gems/*/spec
rm -rf vendor/bundle/ruby/*/gems/*/test
