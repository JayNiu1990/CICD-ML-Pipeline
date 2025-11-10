install:
	pip install --upgrade pip && pip install -r requirements.txt

format:
	pip install black
	black *.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
   
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
   
	cml comment create report.md
update-branch:
	git config --global user.name "yufu_niu"
	git config --global user.email "yufu.niu@gmail.com"
	git checkout -B update
	git add Results/ report.md || echo "No results to add."
	git commit -m "Update with new results" || echo "No changes to commit."
	git push --force origin update
hf-login:
	git fetch origin update
	git merge origin/update --no-edit || true
	git switch update
	pip install -U "huggingface_hub[cli]"
	hf auth login --token $(HF) --add-to-git-credential
push-hub:
	hf upload YufuNiu/ML_Pipeline ./APP --repo-type=space --commit-message="Sync App files"
	hf upload YufuNiu/ML_Pipeline ./Model /Model --repo-type=space --commit-message="Sync Model"
	hf upload YufuNiu/ML_Pipeline ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub
