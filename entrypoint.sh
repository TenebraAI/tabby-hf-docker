#!/bin/bash

python model_downloader.py
python main.py --host 0.0.0.0 --port 80 --config /app/config/tabby.yaml
