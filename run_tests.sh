#!/usr/bin/env bash

NO_RUN_TESTS=("betcrop/cropvolume" "betcrop/fslbetcrop" "denoising/nlmeans" "preproc/gibbs" "preproc/n4" "reconst/diffusivitypriors" "reconst/noddi" "reconst/fodf" "tracking/pfttracking")

if [ -f "failed_tests.txt" ]
then
rm -rf failed_tests.txt
fi

if [ -f "successful_tests.txt" ]
then
rm -rf successful_tests.txt
fi

for test_category in tests/modules/nf-scil/*
do

for test_case in $test_category/*
do

test_instance="$(basename $test_category)/$(basename $test_case)"

if [[ ${NO_RUN_TESTS[@]} =~ $test_instance ]]
then
echo "Skipping $test_instance"
else
{
    nf-core modules create-test-yml --run-tests --force --no-prompts $test_instance &&
    echo "$test_instance" >> successful_tests.txt
} || echo "$test_instance" >> failed_tests.txt

fi

done

done