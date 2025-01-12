"""Generate stories to fine-tune TinyStories with Bitcoin knowledge."""

# Create a file in this same folder: `.env`
# OPENAI_API_KEY=your-api-key
from openai import OpenAI
from dotenv import load_dotenv
import os
import random

# Load the .env file
load_dotenv()

client = OpenAI(
    # This is the default and can be omitted
    api_key=os.environ.get("OPENAI_API_KEY"),
)

topics = [
    "ice cream",
    "Dinosaurs",
    "Unicorns",
    "Rainbows",
    "Fairy tales",
    "Space",
    "Trains",
    "Pirates",
    "Mermaids",
    "Superheroes",
    "Princesses",
    "Construction vehicles",
    "Balloons",
    "Kites",
    "Ice cream",
    "Baking cookies",
    "Playing with dolls",
    "Building blocks",
    "Hide and seek",
    "Musical instruments",
    "Dancing",
    "Singing",
    "Drawing",
    "Painting",
    "Playing dress-up",
    "Tea parties",
    "Zoo animals",
    "Farm animals",
    "Going to the park",
    "Swinging",
    "Slides",
    "Playgrounds",
    "Sandcastles",
    "Swimming",
    "Sea creatures",
    "Fish",
    "Camping",
    "Hiking",
    "Gardening",
    "Butterflies",
    "Ladybugs",
    "Bees",
    "Birds",
    "Bunnies",
    "Puppies",
    "Kittens",
    "Puzzles",
    "Board games",
    "Counting",
    "Alphabet",
    "Colors",
    "Shapes",
    "Numbers",
    "Weather",
    "Seasons",
    "Christmas",
    "Halloween",
    "Birthday parties",
    "Fireworks",
    "Magic tricks",
    "Costumes",
    "Face painting",
    "Carnivals",
    "Circus",
    "Clowns",
    "Jugglers",
    "Storytime",
    "Bedtime stories",
    "Reading books",
    "Library visits",
    "School",
    "ABC's",
    "123's",
    "Pets",
    "Fish tanks",
    "Goldfish",
    "Hamsters",
    "Rabbits",
    "Guinea pigs",
    "Turtles",
    "Dinosaurs",
    "Astronauts",
    "Moon",
    "Stars",
    "Planets",
    "Rocket ships",
    "Aliens",
    "Monsters",
    "Robots",
    "Trains",
    "Cars",
    "Bicycles",
    "Scooters",
    "Skateboards",
    "Helicopters",
    "Airplanes",
    "Hot air balloons",
    "Boats",
    "Submarines",
    "Lighthouses",
    "Castles",
    "Knights",
    "Dragons",
    "Wizards",
    "Spells",
    "Potions",
    "Goblins",
    "Fairies",
    "Elves",
    "Trolls",
    "Witches",
    "Haunted houses",
    "Ghosts",
    "Zombies",
    "Vampires",
    "Werewolves",
    "Mummies",
    "Skeletons",
    "Pumpkins",
    "Jack-o-lanterns",
    "Christmas trees",
    "Santa Claus",
    "Reindeer",
    "Snowmen",
    "Snowflakes",
    "Sledding",
    "Snowball fights",
    "Ice skating",
    "Making snow angels",
    "Igloos",
    "Polar bears",
    "Penguins",
    "Arctic animals",
    "Desert animals",
    "Jungle animals",
    "Rainforest",
    "Safari",
    "Zoo trips",
    "Aquariums",
    "Sea life",
    "Fishing",
    "Boating",
    "River",
    "Lakes",
    "Ocean",
    "Beaches",
    "Seashells",
    "Starfish",
    "Crabs",
    "Sharks",
    "Whales",
    "Dolphins",
    "Seahorses",
    "Octopus",
    "Jellyfish",
    "Coral reefs",
    "Pirates",
    "Treasure hunts",
    "Maps",
    "Compasses",
    "Ships",
    "Flags",
    "Parrots",
    "Monkey",
    "Jungle gyms",
    "Treehouses",
    "Climbing trees",
    "Picnics",
    "Butterfly catching",
    "Frogs",
    "Tadpoles",
    "Snakes",
    "Lizards",
    "Geckos",
    "Chameleons",
    "Crocodiles",
    "Alligators",
    "Tigers",
    "Lions",
    "Elephants",
    "Giraffes",
    "Zebras",
    "Kangaroos",
    "Koalas",
    "Pandas",
    "Sloths",
    "Cheetahs",
    "Leopards",
    "Hippos",
    "Rhinos",
    "Bears",
    "Foxes",
    "Wolves",
    "Deer",
    "Moose",
    "Elk",
    "Caribou",
    "Squirrels",
    "Chipmunks",
    "Raccoons",
    "Beavers",
    "Otters",
    "Hedgehogs",
    "Porcupines",
    "Skunks",
    "Bats",
    "Owls",
    "Hawks",
    "Eagles",
    "Falcons",
    "Parrots",
    "Cockatoos",
    "Canaries",
    "Finches",
    "Peacocks",
    "Penguins",
    "Flamingos",
    "Pelicans",
    "Seagulls",
    "Pigeons",
    "Sparrows",
    "Robins",
    "Blue jays",
    "Cardinals",
    "Hummingbirds",
    "Woodpeckers",
    "Swans",
    "Geese",
    "Ducks",
    "Turkeys",
    "Chickens",
    "Roosters",
    "Hens",
    "Chicks",
    "Eggs",
    "Nests",
    "Birdhouses",
    "Bird feeders",
    "Bird baths",
    "Gardens",
    "Flowers",
    "Trees",
    "Plants",
    "Vegetables",
    "Fruits",
    "Herbs",
    "Bugs",
    "Insects",
    "Ants",
    "Beetles",
    "Caterpillars",
    "Butterflies",
    "Moths",
    "Grasshoppers",
    "Crickets",
    "Ladybugs",
    "Fireflies",
    "Dragonflies",
    "Spiders",
    "Webs",
    "Bees",
    "Honey",
    "Beekeeping",
    "Worms",
    "Snails",
    "Slugs",
    "Centipedes",
    "Millipedes",
    "Scorpions",
    "Nature walks",
    "Hiking",
    "Camping",
    "Backpacking",
    "Fishing",
    "Mountain climbing",
    "Caving",
    "Rock climbing",
    "Stargazing",
    "Constellations",
    "Telescope",
    "Microscope",
    "Magnifying glass",
    "Science experiments",
    "Lab coats",
    "Safety goggles",
    "Beakers",
    "Test tubes",
    "Mixing potions",
    "Bubbles",
    "Bubble baths",
    "Playing with rubber ducks",
    "Bath toys",
    "Splashing in puddles",
    "Rainy days",
    "Jumping in puddles",
    "Mud pies",
    "Mud baths",
    "Dirty hands",
    "Washing hands",
    "Brushing teeth",
    "Combing hair",
    "Getting dressed",
    "Putting on shoes",
    "Tying shoelaces",
    "Buttons",
    "Zippers",
    "Snaps",
    "Velcro",
    "Lace",
    "Ribbons",
    "Bows",
    "Hats",
    "Gloves",
    "Scarves",
    "Jackets",
    "Coats",
    "Sweaters",
    "Pajamas",
    "Slippers",
    "Blankets",
    "Pillows",
    "Stuffed animals",
    "Teddy bears",
    "Puppets",
    "Marionettes",
    "Hand puppets",
    "Shadow puppets",
    "Puppet shows",
    "Toy cars",
    "Trucks",
    "Racecars",
    "Motorcycles",
    "Boats",
    "Planes",
    "Trains",
    "Helicopters",
    "Spaceships",
    "Robots",
    "Action figures",
    "Superheroes",
    "Villains",
    "Toy soldiers",
    "Toy animals",
    "Dollhouses",
    "Play kitchens",
    "Tea sets",
    "Toy food",
    "Play money",
    "Cash registers",
    "Stuffed animals",
    "Plush toys",
    "Building blocks",
    "Legos",
    "Duplos",
    "Lincoln Logs",
    "Wooden blocks",
    "Magnetic tiles",
    "Tinker toys",
    "K'nex",
    "Model trains",
    "Model cars",
    "Model planes",
    "RC cars",
    "RC boats",
    "RC planes",
    "Drones",
    "Kites",
    "Paper airplanes",
    "Frisbees",
    "Balls",
    "Soccer balls",
    "Football",
    "Basketball",
    "Baseball",
    "Tennis",
    "Ping pong",
    "Badminton",
    "Volleyball",
    "Dodgeball",
    "Four square",
    "Jump rope",
    "Hopscotch",
    "Tag",
    "Hide and seek",
    "Simon says",
    "Duck duck goose",
    "Musical chairs",
    "Freeze dance",
    "Ring around the rosie",
    "Hot potato",
    "Red light green light",
    "Mother may I",
    "Follow the leader",
    "Treasure hunts",
    "Scavenger hunts",
    "Nature walks",
    "Hiking",
    "Backpacking",
    "Camping",
    "Fishing",
    "Mountain climbing",
    "Caving",
    "Rock climbing",
    "Stargazing",
    "Constellations",
    "Telescopes",
    "Microscopes",
    "Magnifying glasses",
    "Science experiments",
    "Lab coats",
    "Safety goggles",
    "Beakers",
    "Test tubes",
    "Mixing potions",
    "Bubbles",
    "Bubble baths",
    "Rubber ducks",
    "Bath toys",
    "Splashing in puddles",
    "Rainy days",
    "Jumping in puddles",
    "Mud pies",
    "Mud baths",
    "Dirty hands",
    "Washing hands",
    "Brushing teeth",
    "Combing hair",
    "Getting dressed",
    "Putting on shoes",
    "Tying shoelaces",
    "Buttons",
    "Zippers",
    "Snaps",
    "Velcro",
    "Lace",
    "Ribbons",
    "Bows",
    "Hats",
    "Gloves",
    "Scarves",
    "Jackets",
    "Coats",
    "Sweaters",
    "Pajamas",
    "Slippers",
    "Blankets",
    "Pillows",
    "Stuffed animals",
    "Teddy bears",
    "Puppets",
    "Marionettes",
    "Hand puppets",
    "Shadow puppets",
    "Puppet shows",
    "Toy cars",
    "Trucks",
    "Racecars",
    "Motorcycles",
    "Boats",
    "Planes",
    "Trains",
    "Helicopters",
    "Spaceships",
    "Robots",
    "Action figures",
    "Superheroes",
    "Villains",
    "Toy soldiers",
    "Toy animals",
    "Dollhouses",
    "Play kitchens",
    "Tea sets",
    "Toy food",
    "Play money",
    "Cash registers",
    "Stuffed animals",
    "Plush toys",
    "Building blocks",
    "Legos",
    "Duplos",
    "Lincoln Logs",
    "Wooden blocks",
    "Magnetic tiles",
    "Tinker toys",
    "K'nex",
    "Model trains",
    "Model cars",
    "Model planes",
    "RC cars",
    "RC boats",
    "RC planes",
    "Drones",
    "Kites",
    "Paper airplanes",
    "Frisbees",
    "Balls",
    "Soccer balls",
    "Football",
    "Basketball",
    "Baseball",
    "Tennis",
    "Ping pong",
    "Badminton",
    "Volleyball",
    "Dodgeball",
    "Four square",
    "Jump rope",
    "Hopscotch",
    "Tag",
    "Hide and seek",
    "Simon says",
    "Duck duck goose",
    "Musical chairs",
    "Freeze dance",
    "Ring around the rosie",
    "Hot potato",
    "Red light green light",
    "Mother may I",
    "Follow the leader",
    "Treasure hunts",
    "Scavenger hunts",
    "bycicle",
    "balloon",
    "beach",
    "swimming pool",
    "wizard",
    "squirrel",
    "rabbit",
    "football",
    "tree",
    "cheese",
    "Macaroni and cheese",
    "Chicken nuggets",
    "Pizza",
    "Grilled cheese sandwich",
    "Hot dogs",
    "Hamburgers",
    "Spaghetti",
    "Pancakes",
    "Waffles",
    "French toast",
    "Scrambled eggs",
    "Omelette",
    "Peanut butter and jelly sandwich",
    "Cheese quesadilla",
    "Tacos",
    "Mini sliders",
    "Fish sticks",
    "Corn dogs",
    "Cheese sticks",
    "Carrot sticks",
    "Apple slices",
    "Banana slices",
    "Grapes",
    "Strawberries",
    "Blueberries",
    "Raspberries",
    "Watermelon",
    "Pineapple chunks",
    "Orange slices",
    "Kiwi",
    "Cantaloupe",
    "Mango slices",
    "Pear slices",
    "Peach slices",
    "Cherry tomatoes",
    "Celery sticks",
    "Cucumber slices",
    "Bell pepper strips",
    "Broccoli florets",
    "Cauliflower florets",
    "Mini muffins",
    "Cupcakes",
    "Cookies",
    "Brownies",
    "Rice Krispies treats",
    "Pudding cups",
    "Jello cups",
    "Yogurt",
    "Fruit snacks",
    "Cheese cubes",
    "String cheese",
    "Popcorn",
    "Pretzels",
    "Goldfish crackers",
    "Animal crackers",
    "Graham crackers",
    "Cheese crackers",
    "Veggie sticks",
    "Fruit leather",
    "Apple sauce",
    "Smoothies",
    "Milkshakes",
    "Ice cream",
    "Frozen yogurt",
    "Popsicles",
    "Fruit salad",
    "Trail mix",
    "Granola bars",
    "Peanut butter crackers",
    "Ham and cheese roll-ups",
    "Turkey and cheese roll-ups",
    "Mini bagels with cream cheese",
    "Mini pancakes",
    "Mini waffles",
    "Mini quiches",
    "Meatballs",
    "Chicken tenders",
    "Mini tacos",
    "Soft pretzels",
    "Baked potato wedges",
    "Sweet potato fries",
    "Zucchini fries",
    "Cinnamon rolls",
    "Doughnuts",
    "Marshmallows",
    "S'mores",
    "Chocolate-covered strawberries",
    "Banana bread",
    "Pumpkin bread",
    "Blueberry muffins",
    "Chocolate chip muffins",
    "Mini pizzas",
    "Mini corndogs",
    "Cheese dip",
    "Hummus",
    "Mini meat pies",
    "Fruit kabobs",
    "Veggie kabobs",
    "Cheese and crackers",
    "Mini sandwiches"
]
def generate_story( topic ):
    prompt = (
        f"Write a children's story for a 4-year-old about a teddy bear named Charles. "
        f"Charles does a fun thing that results in him buying or trading an item using his bitcoin wallet. "
        f"Mention the cost of the item in bitcoin. The price must be realistic, in the range of 0.00001 to ckBTC. "
        f"Make the story about {topic}"
        f"Do NOT mention the price in US dollars"
        f"The story must be less than 100 words"
        f"Do NOT start the story with 'Once upon a time' or similar..."
        f"Do NOT start the story with 'Charles the teddy bear'"
    )

    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
                "max_tokens": "200",
            }
        ],
        model="gpt-3.5-turbo",
        # model="gpt-4",
    )
    story = chat_completion.choices[0].message.content.strip()
    return story

def split_into_lines(text, line_length):
    words = text.split()
    lines = []
    current_line = ""
    for word in words:
        if len(current_line) + len(word) + 1 > line_length:
            lines.append(current_line)
            current_line = word
        else:
            if current_line:
                current_line += " " + word
            else:
                current_line = word
    if current_line:
        lines.append(current_line)
    return lines

if __name__ == "__main__":
    filename = "charles-goes-bitcoin.txt"
    with open(filename, "a") as file:
        for i in range(100000):
            topic = random.choice(topics)
            story = generate_story(topic)
            print(f"-- Story: {i}")
            print(story)
            lines = split_into_lines(story, 80)
            for line in lines:
                file.write(line + "\n")
            file.write("<|endoftext|>\n\n")
    print(f"Stories written to {filename}")
