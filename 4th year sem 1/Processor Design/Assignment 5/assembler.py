opcodes = {'lw':"0000",'sw':"0001",'addi':"0010",'add':"0011",'sub':"0100"}
registers = {'$zero':'00','$t0':'01','$t1':'10','$t2':'11'}

def assemble(line):

        i=line.index('$')
        op = line[:i]
        line = line[i:].split(',')
        if op in ('lw', 'sw'):
            rt = line[0]
            rs = line[1].split('(')
            rd = "{:04b}".format(((1 << 4) - 1) & int(rs[0]))
            rs = rs[1][:-1]
        elif op == 'addi':
            rt = line[0]
            rs = line[1]
            rd = "{:04b}".format(((1 << 4) - 1) & int(line[2]))
        else:
            rt = line[2]
            rs = line[1]
            rd = '00'+registers[line[0]]
        return opcodes[op]+registers[rs]+registers[rt]+rd

with open(input("Enter Assembly File: ")) as f:
        lines = f.readlines()
print("\nMACHINE CODE", "HEX")
output = ""
for i in lines:
        if '#' in i:
                i = i[:i.index('#')] #remove comments
        i = "".join(i.split()) #remove whitespace
        if not i:
                continue # skip if line has no code
        code = assemble(i)
        output += hex(int(code, 2))[2:]+" "
        print(code,hex(int(code, 2)))
with open("machinecode",'w') as f:
        f.write("v2.0 raw\n"+output+"\n")

input()
