import os
import shutil
import argparse


from pathlib import Path
from transformers import (
    AutoConfig,
    AutoModelForMultipleChoice,
    AutoTokenizer,
)


flags = None
root_dir = os.path.abspath(os.path.join(__file__, '../../..'))
default_output_dir = os.path.join(root_dir, 'data/models')


def parse_flags():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-m', '--model_names', required=True, type=str,
        nargs='*', help='Model to download'
    )
    parser.add_argument(
        '-o', '--output_dir', required=False, type=str,
        default=default_output_dir,
        help=f'Output directory to store the model (default: {default_output_dir})'
    )
    parser.add_argument(
        '--overwrite', required=False, action='store_true',
        help='Whether to overwrite requested models (default: false)'
    )
    return parser.parse_args()


def download(model_name, cache_dir):
    model = AutoModelForMultipleChoice.from_pretrained(
        model_name,
        force_download=True,
        cache_dir=cache_dir,
    )
    config = AutoConfig.from_pretrained(
        model_name,
        cache_dir=cache_dir,
        force_download=True,
    )
    tokenizer = AutoTokenizer.from_pretrained(
        model_name,
        cache_dir=cache_dir,
        force_download=True,
    )
    return model, config, tokenizer


def save(prefix, model, config, tokenizer, output_dir):
    to_save = dict(model=model, config=config, tokenizer=tokenizer)
    short_out_dir = '/'.join(os.path.abspath(output_dir).split('/')[-2:])
    for name, obj in to_save.items():
        print(f'Saving {prefix}:{name} to {short_out_dir}')
        obj.save_pretrained(output_dir)


def main(model_names, output_dir, overwrite):
    cache_dir = '/tmp'
    for m_name in model_names:
        model_output = Path(os.path.join(output_dir, m_name))
        if model_output.exists():
            if overwrite:
                shutil.rmtree(model_output)
            else:
                raise RuntimeError(
                    f'Requested model already exists {str(model_output)}.\n'
                    'Pass --overwrite to bypass this mechanism'
                )
        model_output.mkdir(parents=True)
        model_output = str(model_output)
        save(m_name, *download(m_name, cache_dir), model_output)


if __name__ == '__main__':
    args = parse_flags()
    main(args.model_names, args.output_dir, args.overwrite)
