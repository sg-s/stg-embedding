#!/bin/bash/python

# this script checks a folder that has the entire contents of the STG database,
# and finds usable data (control + decentralized)

# get all folders in this folder



from glob import glob
import sys
from os import listdir
from os.path import isfile, join

import shutil  






allfolders = glob("/Volumes/DATA/embedding_data/STG-database-files/*/")


# first, strip "alhamood-" from all the folder names
for i in range(0,len(allfolders)):
	shutil.move(allfolders[i], allfolders[i].replace('alhamood-','')) 



# sys.exit()




allfolders = glob("/Volumes/DATA/embedding_data/STG-database-files/*/")


bad_folders = []

for i in range(0,len(allfolders)):
	print(i)

	# get all files in this folder
	onlyfiles = [f for f in listdir(allfolders[i]) if isfile(join(allfolders[i], f))]

	# should have more than one abf file
	abffiles =  [f for f in onlyfiles if f.find('abf') > 0]

	if len(abffiles) < 2:
		# not enought files, mark as bad and move on
		print("Not enought ABF Files")
		bad_folders.append(allfolders[i])
		continue

	# ok, so it has more than 1 abf file. check that it has a .txt file
	txtfiles =  [f for f in onlyfiles if f.find('txt') > 0]
	txtfiles = [f for f in txtfiles if f.find('READ') == 0] 

	print(txtfiles)

	if len(txtfiles) < 1:
		# not enough files, mark as bad and move on
		print("Not enought txt Files")
		bad_folders.append(allfolders[i])
		continue


	# OK, now read the txt file and check that it has the word decentralzied in it
	f = open(join(allfolders[i],txtfiles[0]), "r")
	dec_ok = False
	pdn_ok = False
	for x in f:
		if x.find('decentralized') > 0:
			dec_ok = True
		if x.find('pdn') >= 0:
			pdn_ok = True

	f.close()

	if (not pdn_ok) or (not dec_ok):
		print("Not decentralzied or no pdn")
		bad_folders.append(allfolders[i])
		continue





for i in range(0,len(bad_folders)):
	print(bad_folders[i])
	shutil.move(bad_folders[i], bad_folders[i].replace('/Volumes/DATA/embedding_data/STG-database-files/','/Volumes/DATA/embedding_data/STG-database-files-useless/')) 