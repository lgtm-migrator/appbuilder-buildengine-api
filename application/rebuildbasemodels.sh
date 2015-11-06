#!/usr/bin/env bash

TABLES=(job build )
SUFFIX="Base"

declare -A models
models["job"]="JobBase"
models["build"]="BuildBase"

for i in "${!models[@]}"; do
    CMD="./yii gii/model --tableName=$i --modelClass=${models[$i]} --generateRelations=1 --enableI18N=1 --overwrite=1 --interactive=0 --ns=\common\models"
    echo $CMD
    $CMD
done
