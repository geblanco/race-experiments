#!/usr/bin/env python

import json
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'file', help='File to extract arguments from',
        type=str
    )
    parser.add_argument(
        '-e', '--extract', help='Fields to extract',
        required=False, type=str, default=None
    )
    parser.add_argument(
        '-x', '--exclude', help='Fields to exclude',
        required=False, type=str, default=None
    )
    return parser.parse_args()


def json_args_to_array_args(json_args):
    array_args = []
    for arg_key, arg_value in json_args.items():
        array_args.append('--' + arg_key)
        if type(arg_value) is bool:
            continue
        # should be stringified?
        array_args.append(str(arg_value))
    return array_args


def main(args):
    json_args = json.load(open(args.file, 'r'))
    if args.extract is not None:
        json_args = json_args[args.extract]
    if args.exclude is not None:
        del json_args[args.exclude]
    array_args = json_args_to_array_args(json_args)
    print(' '.join(array_args))


if __name__ == "__main__":
    args = parse_args()
    main(args)
