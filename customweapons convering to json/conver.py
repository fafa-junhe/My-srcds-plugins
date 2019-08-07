#!/bin/python
import re
s = open("onefile","r")
import ast

# Put a colon after the first string in every line
s1 = re.sub(r'^\s*(".+?")', r'\1:', s.read(), flags=re.MULTILINE)
# add a comma if the last non-whitespace character in a line is " or }
s2 = re.sub(r'(["}])\s*$', r'\1,', s1, flags=re.MULTILINE)
data = ast.literal_eval('{' + s2 + '}')
