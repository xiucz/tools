#!/usr/bin/python

'''-----------------------------------
Tool to split BED files per chromosome
-----------------------------------'''

#import modules
import os,sys
from optparse import OptionParser

class bcolors:
    FAIL = '\033[91m'
    ENDC = '\033[0m'

def main():
	usage = "\n%prog  [options]"
	parser = OptionParser(usage)
	parser.add_option("-b","--BED_file",action="store",dest="bed_file",help="Original BED file that should be split per chromosome.")
	parser.add_option("-d","--directory",action="store",dest="directory",default="./",help="Directory where the BED files per chromosome should be created. Default = current directory")
	parser.add_option("-s", "--split",action="store_true",dest="split_strand",default=False,help="Additionally split each file per strand.")

	(options,args)=parser.parse_args()

	#check if bed_file was given
	if not options.bed_file:
		print >>sys.stderr, bcolors.FAIL + "\nError: no BED file defined\n" + bcolors.ENDC
		parser.print_help()
		sys.exit(0)

	#check if directory was given and if not, use current directory
	if not options.directory:
		options.directory = "./"

	#check if directory ends with / and if not, add it
	if options.directory[-1] != "/":
		options.directory = options.directory + "/"

	#check if directory exists and if not, make it
	if not os.path.exists(options.directory):
		os.makedirs(options.directory)

	#get name of the BED file
	bed_name = os.path.basename(options.bed_file)
	bed_name = bed_name[:-4]

	#this is where the magic happens
	file_list = {}
	count = 0
	bed_file = open(options.bed_file)
	for line in bed_file:
		count +=1
		fields = line.split()
		file_name = str(options.directory + str(bed_name) + '_' + str(fields[0]))
		
		#add strand name when splitting by strand
		if options.split_strand is True:
			if fields[5] == '+':
				file_name = str(file_name + '_' + 'pos')
			if fields[5] == '-':
				file_name = str(file_name + '_' + 'neg')

		#check if chromosome file already exists and if not, make it
		if file_name not in file_list:
			file = open('%s.bed' % file_name, 'w+')
			file_list[file_name] = file
		
		#write lines to the correct chromosome file
		file_list[file_name].write(line)

		#show gene count to not fall asleep
		print >>sys.stderr, "%d genes finished\r" % count,

	#close all the files
	for key, value in file_list.iteritems():
		value.close
	bed_file.close

if __name__ == '__main__':
	main()
