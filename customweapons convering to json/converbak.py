#!/bin/python
import re
import json
import os
s = open("a.json","r")
sdict = json.load(s)
import ast
for weapon in sdict:
    b = str(sdict[weapon])
    txt = re.sub(r'[,]', '\n', b, flags=re.MULTILINE)
    txt = re.sub(r'[:]', '      ', txt, flags=re.MULTILINE)
    txt = txt.replace("{","{\n")
    txt = txt.replace("}","\n}")
    txt = txt.replace("\'","\"")
    txt = "\"" + weapon +"\"\n" + txt
    open(os.getcwd()+"/output/"+weapon+".txt",'w').write(txt)
