# race-experiments
Experiements conducted at UNED with the multiple-choice question answering dataset RACE

## scripts
Training with [this transformers fork](https://github.com/m0n0l0c0/transformers) will produce `nbest_predictions` files just like training for SQuAD. This predictions can be used to calculate [c@1](https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response) or estimate a threshold to give empty answers.

To estimate the threshold parameter of a multilingual BERT model (you have to finetune it first):
```bash
python ./scripts/threshold.py results/multi-bert_is_test_false_eval_nbest_predictions.json
```

To calculate the c@1 value for RACE test set you have to compile the test split of RACE to a single file understandable by the evaluation script (`./scripts/ee_evaluation.py`):
```bash
# compile the dataset
compiled_dataset="../datasets/RACE/test/race_test_compiled_high.json"
predictions="results/multi-bert-high_is_test_true_eval_nbest_predictions.json"
python scripts/utils_race.py --data ../datasets/RACE/test --partition high > $compiled_dataset
# evaluate results, aplying previously obtained threshold
python scripts/ee_evaluation.py $compiled_dataset $predictions -t 0.3784342485810497
```
