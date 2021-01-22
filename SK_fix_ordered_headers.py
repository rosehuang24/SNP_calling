#input: vcf with header ordered in sk, ynlc, tlf, lx, rjf, yvc, dl,tbc and wlh. 96 individuals (partTBC)
# ./.is missing allele, it is not included in allele frequency calculation.
# This script can be modified to filter for alternate high fix or reference high fix in any population. 
# SNPs or SV both works? Must be biallelic

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

d={"0/0":"0", "0|0":"0","0/1":"1","0|1":"1", "1/1":"2","1|1":"2"}
def AC(a,b):
    pop=[]
    for i in line[a:b]:
        gt=i.split(":")[0]
        if gt!="./.":
            pop.append(int(d[gt]))
    if len(pop)!=0:
        pop_p=round(sum(pop)/(2*(len(pop)))*1000)
        number_sum.append(pop_p)

for lines in inh:
    if not lines.startswith("#"):
        number_sum=[]
        line=lines.strip().split()
        sk=[]
        for i in line[9:32]:
            gt=i.split(":")[0]
            if gt!="./.":
                sk.append(int(d[gt]))
        if len(sk)!=0:
            sk_p=round(sum(sk)/(2*len(sk))*1000)
            if sk_p>699:
                AC(32,40)
                AC(40,46)
                AC(46,56)
                AC(56,66)
                AC(66,74)
                AC(74,84)
                AC(84,92)
                AC(92,105)
            if len(number_sum)>0:
                number_sum.sort()
                if number_sum[-1] < 301:
                    outh.write(lines)

            
inh.close()
outh.close()
            
            
            
