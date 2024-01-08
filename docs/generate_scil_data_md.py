#!/usr/bin/env python3

import argparse
import importlib
import os
from tempfile import TemporaryDirectory
import requests
import sys


def create_parser():
    _p = argparse.ArgumentParser(
        description='Generate markdown reference for Scil data')

    _p.add_argument("output_file")

    return _p


def _unpack_archive(_upload_root, _archive, _test_dict, _fetcher):
    _fetcher(_test_dict, _archive)

    return os.path.join(_upload_root, ".".join(_archive.split(".")[:-1]))



def main():
    parser = create_parser()
    args = parser.parse_args()

    fetcher = "https://github.com/scilus/scilpy/raw/master/scilpy/io/fetcher.py"
    response = requests.get(fetcher)

    with open(args.output_file, "w+") as md_file:

        md_file.writelines([
            "# Scilpy fetcher datasets\n"
            "\n",
            "Datasets available in Scilpy data.\n",
            "Entries are indexed by archive name.\n"])

        with TemporaryDirectory() as tmp_dir:

            temp_data_dir = os.path.join(tmp_dir, "scilpy_data")
            os.makedirs(temp_data_dir)
            os.environ["SCILPY_HOME"] = temp_data_dir

            with open(tmp_dir + '/fetcher.py', 'w') as f:
                f.write(response.text)

            spec = importlib.util.spec_from_file_location(
                "scilpy_fetcher", tmp_dir + '/fetcher.py')
            module = importlib.util.module_from_spec(spec)
            sys.modules["scilpy_fetcher"] = module
            spec.loader.exec_module(module)

            from scilpy_fetcher import fetch_data, get_testing_files_dict

            test_dict = get_testing_files_dict()

            for archive, _ in test_dict.items():
                data_root = _unpack_archive(
                    temp_data_dir, archive, test_dict, fetch_data)

                md_file.writelines([f" - {archive}\n"])
                for root, _, files in os.walk(data_root):
                    md_file.writelines(
                        [f"     - {file}\n" for file in files])


if __name__ == '__main__':
    main()
