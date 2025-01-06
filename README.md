# Charles

Charles is an AI NFT, running on the Internet Computer.

# Model

Download from https://huggingface.co/onicai/charles/tree/main
Files are `model.bin` & `tok4096.bin`
Store in the folder: ./models/out-09

# Images

The images are in this Google drive: https://drive.google.com/drive/u/0/folders/15hxZWQN_ziQpX6VgMOUPNYNiG6gv5APz

# Run llama2.c from command line

To do some prompt testing, it is nice to run llama2.c directly from the llama2.c github repo.

```bash
git clone https://github.com/icppWorld/llama2.c
cd llama2.c

conda create --name llama2-c python=3.10
conda activate llama2-c
pip install -r requirements.txt

make run

# Example command
./run ../charles/models/out-09/model.bin -z ../charles/models/out-09/tok4096.bin -t 0.1 -p 0.9 -i "Charles loves ice cream"
```

# Backend

Instructions in `backend/README-bioniq-setup.md`

# Frontend

Instructions in `frontend/README.md`