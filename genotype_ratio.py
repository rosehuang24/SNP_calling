#remember to replace all pipe characters to slashes.
#Update: I have corperate that into code. No need to convert seperately.

#the input has to be header arranged
#SK: line[9:32]
#YNLC: line[32:40]
#TLF: line[40:46]
#LX: line[46:56]
#RJF:line[56:66]
#YVC: line[66:74]
#DL: line[74:84]
#TBC: line[84:92]
#WLH: line[92:105]
# Change upon use!

import sys

infile = sys.argv[1]
inh = open(infile, 'r')
outfile = sys.argv[2]
outh = open(outfile, 'w')

def AC(a,b):
    hom=0
    het=0
    ref=0
    miss=0
    for i in line[a:b]:
        gt=i.split(":")[0]
        if gt=="./.":
            miss+=1
        if gt=="0/0":
            ref+=1
        if gt=="0/1":
            het+=1
        if gt=="1/1":
            hom+=1
    ratio.append(str(hom)+":"+str(het)+":"+str(ref)+":"+str(miss))


for lines in inh:
    if not lines.startswith("#"):
        line=lines.strip().replace("|", "/").split()
        ratio=[]
        AC(9,32)
        AC(32,105)
        outh.write(line[0]+"\t"+line[1]+"\t"+'\t'.join(ratio)+"\n")
        
inh.close()
outh.close()
