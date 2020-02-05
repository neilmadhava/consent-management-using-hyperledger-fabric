import json
# from pprint import pprint
from termcolor import colored

valid_colors = ("red", "green", "yellow", "blue", "magenta", "cyan", "white")
json_file = './scripts/queryResults.json'

with open(json_file) as json_data:
    data = json.load(json_data)

for key in data.keys():
	print(colored(key, color="yellow") + ": " + data[key])
