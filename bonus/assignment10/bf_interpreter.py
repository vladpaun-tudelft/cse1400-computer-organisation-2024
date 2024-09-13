program = input()
stack = [0]
sp = 0

user_input = []

brackets = []
brackets_dict = {}

# Parse all the loop '[]' and store them in a 2 way lookup dict
    # Have a key for each '[' with the value being its respective ']' and the reverse
for ip, instruction in enumerate(program):
    if instruction == '[':
        brackets.append(ip)
    elif instruction == ']':
        loop_start_index = brackets.pop(0)

        brackets_dict[ip] = loop_start_index
        brackets_dict[loop_start_index] = ip

# Actual loop to interpret
ip = 0
counter = 0
while ip < len(program):
    instruction = program[ip]

    if instruction == '+':
        stack[sp] += 1
        if stack[sp] == 256:
            stack[sp] = 0
    elif instruction == '-':
        stack[sp] -= 1
        if stack[sp] == -1:
            stack[sp] = 255
    elif instruction == '>':
        sp += 1
        if sp == len(stack):
            stack.append(0)
    elif instruction == '<':
        sp -= 1
    elif instruction == '.':
        print(chr(stack[sp]), end='')
    elif instruction == ',':
        if user_input == []:
            user_input = list(input() + '\n')
        stack[sp] = ord(user_input.pop(0))
        
    elif instruction == '[':
        if stack[sp] == 0:
            ip = brackets_dict[ip]
    elif instruction == ']':
        if stack[sp] != 0:
            ip = brackets_dict[ip]


    ip += 1

print('')