# nftData

This folder contains the `storybookNFTS.json` file that is loaded into the NFT canister at bioniq.

It also contains all the python notebooks that we used to generate it. 

The title of each notebook explains what it is doing, but it was a highly iterative process.

## OpenAI

Create a file `nftData/.env`, and store your OpenAI API Key:

```
OPENAI_API_KEY=sk-proj-xxxxxx
```

## Images

Download the images from this Google drive: https://drive.google.com/drive/u/0/folders/15hxZWQN_ziQpX6VgMOUPNYNiG6gv5APz

Open all the notebooks (*.ipynb) in VS Code, and update the path to the images.

## Python

Create a python environment with the required dependencies installed:

We use MiniConda:

```
conda create --name charles-nftData python=3.11
conda activate charles-nftData

# from nftData folder:
pip install -r requirements.txt
```

## Run the notebooks

Now open the notebooks (*.ipynb) in VS Code, and run them:
- you must have the VS Code Python extension installed
- when prompted to select the Python kernel, select the `charles-nftData` miniconda environment