#remember to replace all pipe characters to slashes.

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
# especially the frequency
#output is barely for one position and if it is fixed for ref for alt base

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
    if (ref+het+hom) != 0:
        alt_freq=round(1000*((hom*2+het)/((ref+het+hom)*2)))
        ref_freq=round(1000*((ref*2+het)/((ref+het+hom)*2)))
        #ref_freq=round(((het+ref*2)/(2*ref+het+hom))*1000)
        alt_ls.append(alt_freq)
        ref_ls.append(ref_freq)

for lines in inh:
    if not lines.startswith("#"):
        line=lines.strip().replace("|", "/").split()
        alt_ls=[]
        ref_ls=[]
        for i in line[9:32]:
            hom=0
            het=0
            ref=0
            miss=0
            for i in line[9:32]:
                gt=i.split(":")[0]
                if gt=="./.":
                    miss+=1
                if gt=="0/0":
                    ref+=1
                if gt=="0/1":
                    het+=1
                if gt=="1/1":
                    hom+=1
        if (ref+het+hom) != 0:
            sk_alt_freq=round(1000*((hom*2+het)/((ref+het+hom)*2)))
            sk_ref_freq=round(1000*((ref*2+het)/((ref+het+hom)*2)))
            #print(line[1]+"\t"+str(sk_alt_freq)+"\t"+str(hom)+":"+str(het)+":"+str(ref)+":"+str(miss))

        if sk_alt_freq > 699:
            AC(32,40)
            AC(40,46)
            AC(46,56)
            AC(66,74)
            AC(74,84)
            AC(84,92)
            AC(92,105)
            alt_ls.sort()
            if alt_ls[-1] < 301:
            #    print(line[1]+"\t"+str(sk_alt_freq)+"\t"+str(alt_ls))
                outh.write(line[0]+"\t"+line[1]+"\tAlternate\n")

        if sk_ref_freq > 699:
            AC(32,40)
            AC(40,46)
            AC(46,56)
            AC(66,74)
            AC(74,84)
            AC(84,92)
            AC(92,105)
            ref_ls.sort()
            if ref_ls[-1]< 301:
                #print(line[1]+"\t"+str(sk_alt_freq)+"\t"+str(ref_ls))
                outh.write(line[0]+"\t"+line[1]+"\tReference\n")

inh.close()
outh.close()
