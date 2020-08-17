# race-experiments
Experiments conducted at UNED with the multiple-choice question answering dataset RACE

## Reproduction
We use [DVC](https://dvc.org) for reproducibility. In order to use set it up (if you have not already):
```bash
# setup your remote, any local dir will do really
mkdir ~/dvc_cache
dvc config --local core.remote local_dvc
dvc remote add --local -d local_dvc "~/dvc_cache"
```

And reproduce the end of the pipeline
```bash
dvc repro
```

## Experiments
Every experiment has a _json_ specification file in the experiments folder. With this file, a special directory structure is created inside the data folder, with metrics, models, results and spec (generated with [rosetta](https://github.com/geblanco/rosetta))

## scripts
Training will produce `nbest_predictions` files just like training for SQuAD. This predictions can be used to calculate [c@1](https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response) or estimate a threshold to give empty answers.

<!-- To estimate the threshold parameter of a multilingual BERT model (you have to finetune it first):
```bash
python ./evaluation/threshold.py results/multi-bert_is_test_false_eval_nbest_predictions.json
```

To calculate the c@1 value for RACE test set you have to compile the test split of RACE to a single file understandable by the evaluation script (`./evaluation/evaluation.py`):
```bash
# compile the dataset
compiled_dataset="../datasets/RACE/test/race_test_compiled_high.json"
predictions="results/multi-bert-high_is_test_true_eval_nbest_predictions.json"
python evaluation/compile_race.py --data ../datasets/RACE/test --partition high > $compiled_dataset
# evaluate results, aplying previously obtained threshold
python evaluation/evaluation.py $compiled_dataset $predictions -t 0.3784342485810497
```
 -->