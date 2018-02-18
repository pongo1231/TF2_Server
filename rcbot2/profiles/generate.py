### Config ###

names_file = "names.txt"
bot_profiles_max_amount = 32

##############

import random
import sys

def fetch_names():
	with open(sys.path[0]+"/"+names_file) as f:
		return f.read().splitlines()

def select_random_names(names):
	gen_names = []
	temp_names = names

	for i in range(0, bot_profiles_max_amount):
		if len(names) == 0:
			break
		index = random.randrange(0, len(names))
		gen_names.append(names[index])
		temp_names.pop(index)
	
	return gen_names

def gen_bot_profiles(gen_names):
	for i in range(1, len(gen_names)+1):
		# Current path
		with open(sys.path[0]+"/"+str(i)+".ini", "w+") as file:
			file.write("name = " + gen_names[i-1])


def main():
	names = fetch_names()
	gen_names = select_random_names(names)
	gen_bot_profiles(gen_names)

main()