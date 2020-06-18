'''
Train collapsed feature classifier on Madrid transfer to ICU task

'''

# Default environment variables
# Can override with local env variables

from config_loader import (
    D_CONFIG,
    DATASET_STD_PATH, DATASET_SPLIT_PATH,
    PROJECT_REPO_DIR, PROJECT_CONDA_ENV_YAML,
    RESULTS_PATH)

RESULTS_PATH = os.path.join(RESULTS_PATH, 'logistic_regression')

rule train_and_evaluate_classifier:
    input:
        script=os.path.join(PROJECT_REPO_DIR, 'src', 'eval_classifier.py'),
        x_train_csv=os.path.join(DATASET_SPLIT_PATH, 'x_train.csv'),
        x_test_csv=os.path.join(DATASET_SPLIT_PATH, 'x_test.csv'),
        y_train_csv=os.path.join(DATASET_SPLIT_PATH, 'y_train.csv'),
        y_test_csv=os.path.join(DATASET_SPLIT_PATH, 'y_test.csv'),
        x_dict_json=os.path.join(DATASET_SPLIT_PATH, 'x_dict.json'),
        y_dict_json=os.path.join(DATASET_SPLIT_PATH, 'y_dict.json')

    output:
        os.path.join(RESULTS_PATH, 'report.html')

    conda:
        PROJECT_CONDA_ENV_YAML

    shell:
        '''
        mkdir -p {{RESULTS_PATH}} && \
        python -u {input.script} \
            logistic_regression \
            --outcome_col_name {{OUTCOME_COL_NAME}} \
            --output_dir {{RESULTS_PATH}} \
            --train_csv_files {input.x_train_csv},{input.y_train_csv} \
            --test_csv_files {input.x_test_csv},{input.y_test_csv} \
            --data_dict_files {input.x_dict_json},{input.y_dict_json} \
            --validation_size 0.15 \
            --key_cols_to_group_when_splitting {{SPLIT_KEY_COL_NAMES}} \
            --n_splits 3 \
            --scoring roc_auc \
            --threshold_scoring balanced_accuracy \
            --class_weight balanced \
	    --tol 0.01\
	    --max_iter 5000\
        '''.replace("{{RESULTS_PATH}}", RESULTS_PATH)\
           .replace("{{OUTCOME_COL_NAME}}", D_CONFIG["OUTCOME_COL_NAME"])\
           .replace("{{SPLIT_KEY_COL_NAMES}}", D_CONFIG["SPLIT_KEY_COL_NAMES"]) 
