import os
from huggingface_hub import snapshot_download

repo_ids = os.getenv("HF_MODELS", "").split(",")
revision = "main"

for repo_id in repo_ids:
    snapshot_download(repo_id=repo_id, revision=revision, local_dir=f"./models/{repo_id.replace('/', '_')}")
    model = repo_id.replace('/', '_')
