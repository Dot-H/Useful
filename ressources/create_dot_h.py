
# coding: utf-8

# In[103]:

import sys

def create_dot_h(filename):
    f = open(filename, "r")
    h_name = filename
    h_name = h_name.replace('.c', '.h')
    h = open(h_name, "w+")
    h_macros = h_name.replace('.', '_').upper();
    h.write("#ifndef " + h_macros + '\n')
    h.write("#define " + h_macros + '\n\n')

    f_lines = f.readlines()
    stack = []
    function = ""
    args = []
    for line in f_lines:
        if line.find("#include") != -1:
            continue
        for c in line[:line.find("//")]:
            if (c == '{'):
                stack.append(c)
            elif (c == '}'):
                stack.pop()
            elif (len(stack) == 0):
                if (c == '\n'):
                    continue
                elif (c == '('):
                    args.append(c)
                elif (c == ')'):
                    args.pop()
                    function += ')'
                    if len(args) == 0:
                        h.write(function + ';\n\n')
                        function = ""
                        continue
                function += c
    h.write("#endif")
    f.close()
    h.close()

if len(sys.argv) != 2:
   print "expected: " + sys.argv[0] + " filename"
else:
    create_dot_h(sys.argv[1])
