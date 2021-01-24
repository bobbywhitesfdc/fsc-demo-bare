#!/bin/bash
set -euxo pipefail
TOKEN=JFHU2UK2LJLUKNSBGNDEMTSJGNFDOQ2CLBJEEQRXGI3DEQKEK5LEWUSYKBIEMQKPLJAUEWCQJJHDGNRVIVEFSU2WIJEFUWCYJNAVERSGLIZFIRSNGJGFKVKHLJGFMSKTJ5FEWV2MIRJFIV2JKIZTKUCDKRIU2RSPKBEVC7COIE
#curl -X POST -H "Authorization: Bearer $TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "type=text-intent" -F "path=http://einstein.ai/text/case_routing_intent.csv" https://api.einstein.ai/v2/language/datasets/upload
DATASET_ID=1249089
#curl -X GET -H "Authorization: Bearer $TOKEN" -H "Cache-Control: no-cache" https://api.einstein.ai/v2/language/datasets/$DATASET_ID
#curl -X POST -H "Authorization: Bearer $TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "name=Service Request Routing Model" -F "datasetId=$DATASET_ID" https://api.einstein.ai/v2/language/train
MODEL_ID=HC5WR5O3C26YAEZTAO7TTV76LU
#curl -X GET -H "Authorization: Bearer $TOKEN" -H "Cache-Control: no-cache" https://api.einstein.ai/v2/language/train/$MODEL_ID

curl -X POST -H "Authorization: Bearer $TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "modelId=$MODEL_ID" -F "document=I'd like to buy some shoes" https://api.einstein.ai/v2/language/intent



