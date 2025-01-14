# Charles training

## Huggingface

You can find the training data created with these scripts at:

https://huggingface.co/datasets/onicai/Charles-training-data


## The scripts

We trained the model following the exact instructions of [karpathy/llama2.c](https://github.com/karpathy/llama2.c)

The complete training data is stored in the folder `data_charles`. It is in the correct JSON format for the training pipeline.

As training data, we used the original tinyStories data-set, augmented with additional stories that we created with OpenAI.

The creation of the additional stories was an interative approach, and we used variations of the scripts:

- 1_generate_btc_stories_version_1.py
- 1_generate_btc_stories_version_2.py

The *.txt files store the result of those runs.

The `2_create_tinystories_training_data.py` script then combines those additional stories with the original tinyStories data-set, and writes it out into 50 json files.