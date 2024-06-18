#!/usr/bin/env bash

NO_RUN_TESTS=( )

rm -rf failed_tests_modules.txt
rm -rf successful_tests_modules.txt
rm -rf failed_tests_subworkflows.txt
rm -rf successful_tests_subworkflows.txt

for test_category in subworkflows/nf-scil/*
do
    test_instance="$(basename $test_category)";
    if [[ ${NO_RUN_TESTS[@]} =~ $test_instance ]];
    then
        echo "Skipping $test_instance"
    else
        echo "Running $test_instance"
        {
        nf-core subworkflows --git-remote http://github.com/scilus/nf-scil test -u $test_instance &&
        echo "Test - $test_instance" >> successful_tests_subworkflows.txt
        } || echo "Test - $test_instance" >> failed_tests_subworkflows.txt;
    fi
done

for test_category in modules/nf-scil/*
do
    for test_case in $test_category/*
    do
        test_instance="$(basename $test_category)/$(basename $test_case)";
        if [[ ${NO_RUN_TESTS[@]} =~ $test_instance ]];
        then
            echo "Skipping $test_instance"
        else
            echo "Running $test_instance"
            {
            nf-core modules --git-remote http://github.com/scilus/nf-scil lint $test_instance &&
            echo "Lint - $test_instance" >> successful_tests_modules.txt
            } || echo "Lint - $test_instance" >> failed_tests_modules.txt;
            {
            nf-test test --update-snapshot modules/nf-scil/$test_instance --profile docker &&
            echo "Test - $test_instance" >> successful_tests_modules.txt
            } || echo "Test - $test_instance" >> failed_tests_modules.txt;
        fi
    done
done
