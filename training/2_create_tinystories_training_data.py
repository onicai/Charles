"""
Processes the stories written to *.txt by generate_btc_stories.py for use by llama2.c

Use as: python -m btc_stories.create_tinystories_training_data create_json_shards
"""

import argparse
import glob
import json
import os
import random
from typing import List
from concurrent.futures import ProcessPoolExecutor
from functools import partial
import pprint
import math
from pathlib import Path
import shutil

# directory where original TinyStories training data is stored
DATA_CACHE_TINY_STORIES = Path(__file__).parent / "../../llama2.c/data/TinyStories_all_data"

# directory where we will store the processed Charles stories
TXT_CACHE_DIR_CHARLES = Path(__file__).parent
DATA_CACHE_DIR_CHARLES = Path(__file__).parent / "data_charles"

def create_json_shards():
    """
    Create the json shards from the charles-*.txt files
    """
    # Read all stories from the txt files
    print("----")
    data_dir = os.path.join(".", "data_charles")
    text_filenames = sorted(glob.glob(os.path.join(TXT_CACHE_DIR_CHARLES, "charles-*.txt")))
    all_stories = []
    for i, fname in enumerate(text_filenames):
        with open(fname, "r") as f:
            content = f.read()

        stories = content.split("<|endoftext|>\n\n")
        stories = [story.replace("\n", " ") for story in stories]
        all_stories.extend(stories)
        print(f"File {fname} has {len(stories)} stories")
        # print("Story 0:")
        # print(stories[0])
        # print("Story 1:")
        # print(stories[1])

    print(f"We have {len(all_stories)} stories for Charles")

    # Replace Charles with a Random name, else the Charles LLM training will ignore the original tiny stories
    names = [
        "Jacob", "Michael", "Joshua", "Matthew", "Daniel", "Christopher", "Andrew", "Ethan", "Joseph", 
        "William", "Anthony", "David", "Alexander", "Nicholas", "Ryan", "Tyler", "James", "John", 
        "Jonathan", "Noah", "Brandon", "Christian", "Dylan", "Samuel", "Benjamin", "Zachary", "Nathan", 
        "Logan", "Justin", "Gabriel", "Jose", "Austin", "Kevin", "Elijah", "Caleb", "Robert", "Thomas", 
        "Jordan", "Cameron", "Jack", "Hunter", "Jackson", "Angel", "Isaiah", "Evan", "Isaac", "Mason", 
        "Luke", "Jason", "Gavin", "Jayden", "Aaron", "Connor", "Aiden", "Aidan", "Kyle", "Juan", 
        "Luis", "Adam", "Lucas", "Brian", "Eric", "Adrian", "Nathaniel", "Sean", "Alex", 
        "Carlos", "Bryan", "Ian", "Owen", "Jesus", "Landon", "Julian", "Chase", "Cole", "Diego", 
        "Jeremiah", "Steven", "Sebastian", "Xavier", "Timothy", "Carter", "Wyatt", "Brayden", "Blake", 
        "Hayden", "Devin", "Cody", "Richard", "Seth", "Dominic", "Jaden", "Antonio", "Miguel", "Liam", 
        "Patrick", "Carson", "Jesse", "Tristan", "Alejandro", "Henry", "Victor", "Trevor", "Bryce", 
        "Jake", "Riley", "Colin", "Jared", "Jeremy", "Mark", "Caden", "Garrett", "Parker", "Marcus", 
        "Vincent", "Kaleb", "Kaden", "Brady", "Colton", "Kenneth", "Joel", "Oscar", "Josiah", "Jorge", 
        "Cooper", "Ashton", "Tanner", "Eduardo", "Paul", "Edward", "Ivan", "Preston", "Maxwell", 
        "Alan", "Levi", "Stephen", "Grant", "Nicolas", "Omar", "Dakota", "Alexis", "George", "Collin", 
        "Eli", "Spencer", "Gage", "Max", "Cristian", "Ricardo", "Derek", "Micah", "Brody", "Francisco", 
        "Nolan", "Ayden", "Dalton", "Shane", "Peter", "Damian", "Jeffrey", "Brendan", "Travis", 
        "Fernando", "Peyton", "Conner", "Andres", "Javier", "Giovanni", "Shawn", "Braden", "Jonah", 
        "Cesar", "Bradley", "Emmanuel", "Manuel", "Edgar", "Erik", "Mario", "Edwin", "Johnathan", 
        "Devon", "Erick", "Wesley", "Oliver", "Trenton", "Hector", "Malachi", "Jalen", "Raymond", 
        "Gregory", "Abraham", "Elias", "Leonardo", "Sergio", "Donovan", "Colby", "Marco", "Bryson", 
        "Martin"
    ]
    print("---")
    print("replacing Charles with a random name...")
    all_stories_ = []
    for story in all_stories:
        selected_name = random.choice(names)  # Randomly select a name from the list
        # In the story string, replace 'Charles' with that name
        modified_story = story.replace("Charles", selected_name)
        all_stories_.append(modified_story)
    all_stories = all_stories_
    for story in all_stories[:10]:
        print("==")
        print(story)

    # Convert the stories into the proper training format
    data = []
    for story in all_stories:
        data.append(
            {
                'instruction': {'features': ['...'],'prompt:': '...', 'words': []},
                'source': 'gpt-3.5-turbo',
                'story': f'{story}',
                'summary': '...'
            }
        )

    # Sample from the original TinyStories data until we have the same number of original stories
    print("----")
    RATIO = 5
    NUM_TINY_STORIES = RATIO*len(data)
    print(f"Sampling {NUM_TINY_STORIES} from the original TinyStories")
    tinystories_filenames = sorted(glob.glob(os.path.join(DATA_CACHE_TINY_STORIES, "*.json")))
    tinystories_data = []
    samples_per_file = NUM_TINY_STORIES / len(tinystories_filenames)
    while True:
        # loop again if we're not there yet
        if len(tinystories_data) >= NUM_TINY_STORIES:
                break
        for i, shard in enumerate(tinystories_filenames):
            with open(shard, "r") as f:
                stories = json.load(f)
                print(f"File {shard} has {len(stories)} stories")

                # Determine how many stories to sample from this shard
                num_samples = int(min(samples_per_file, NUM_TINY_STORIES-len(tinystories_data)))
                print(f"Sampling {num_samples} stories")

                sampled_stories = random.sample(stories, min(len(stories), num_samples))
                tinystories_data.extend(sampled_stories)
        
            
            print(f"We have {len(tinystories_data)} original tinystories")
            if len(tinystories_data) >= NUM_TINY_STORIES:
                break

    print(f"We have {len(tinystories_data)} original tinystories")

    # Randomly take RATIO*len(data) stories from tinystories_data and combine them 
    # with the charles stories. Then shuffle them.
    print("----")
    print(f"Randomly mixing {len(tinystories_data)} original stories with the {len(data)} Charles stories")
    data.extend(tinystories_data)
    random.shuffle(data)
    print(f"We have {len(data)} stories in the combined data set")

    # Write the stories in correct shard *.json format
    print("----")
    if DATA_CACHE_DIR_CHARLES.exists():
        shutil.rmtree(DATA_CACHE_DIR_CHARLES)
    DATA_CACHE_DIR_CHARLES.mkdir(parents=True, exist_ok=True)
    # stories_per_shard = 100000 
    stories_per_shard = int(len(data) / 50) # One shard is used as test set, so make sure we have at least 50
    total_items = len(data)
    num_files = math.ceil(total_items / stories_per_shard)
    
    for i in range(num_files):
        start_index = i * stories_per_shard
        end_index = min(start_index + stories_per_shard, len(data))
        chunk = data[start_index:end_index]
        
        file_path = DATA_CACHE_DIR_CHARLES / f'data{i:02}.json'
        with open(file_path, 'w') as f:
            json.dump(chunk, f, separators=(',', ':'))  # No formatting
        
        print(f'Saved {file_path} with {len(chunk)} items')



def load_a_json_shard():
    """
    Loads a json shard for investigative purposes
    """
    # to load an original tinyStories json
    # DATA_CACHE_DIR = "../..//llama2.c/data" # directory of the original tiny stories JSON files
    # data_dir = os.path.join(DATA_CACHE_DIR, "TinyStories_all_data")
    # to load a charles json
    data_dir = DATA_CACHE_DIR_CHARLES

    shard_filenames = sorted(glob.glob(os.path.join(data_dir, "*.json")))
    for i, shard in enumerate(shard_filenames):
        with open(shard, "r") as f:
            data = json.load(f)
        print("----")
        print(f"Shard {i} has {len(data)} stories")
        print("Story 0:")
        pprint.pprint(data[0])
        print("Story 1:")
        pprint.pprint(data[1])


# -----------------------------------------------------------------------------
# public interface functions

def get_tokenizer_model_path(vocab_size):
    """
    Returns path to the sentencepiece tokenizer model for a given vocab size
    vocab_size = 0 designates the default Llama 2 tokenizer, in that case
    None is returned.
    """
    if vocab_size == 0:
        return None
    else:
        return os.path.join(DATA_CACHE_DIR, f"tok{vocab_size}.model")

class Task:

    @staticmethod
    def iter_batches(batch_size, device, num_workers=0, **dataset_kwargs):
        ds = PretokDataset(**dataset_kwargs)
        dl = torch.utils.data.DataLoader(
            ds, batch_size=batch_size, pin_memory=True, num_workers=num_workers
        )
        for x, y in dl:
            x = x.to(device, non_blocking=True)
            y = y.to(device, non_blocking=True)
            yield x, y

# -----------------------------------------------------------------------------
# CLI for constructing the dataset

if __name__ == "__main__":
    """
    These stages are designed to be run in order.

    To tokenize data with the Llama 2 tokenizer:
    python tinystories.py download
    python tinystories.py pretokenize

    To tokenize data with a custom tokenizer we train ourselves with sentencepiece, e.g.:
    python tinystories.py download
    python tinystories.py train_vocab --vocab_size=2048
    python tinystories.py pretokenize --vocab_size=2048
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("stage", type=str, choices=["create_json_shards", "load_a_json_shard"])
    args = parser.parse_args()

    # depending on the stage call the appropriate function
    if args.stage == "create_json_shards":
        create_json_shards()
    elif args.stage == "load_a_json_shard":
        load_a_json_shard()
    else:
        raise ValueError(f"Unknown stage {args.stage}")
