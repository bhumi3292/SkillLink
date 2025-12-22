from pathlib import Path
p=Path('e:/SkillLink/skill_link/lib/features/dashbaord/presentation/widgets/property_card_widget.dart')
s=p.read_text().splitlines()
paren=0
brace=0
brack=0
stack=[]
for i,line in enumerate(s,1):
    for j,ch in enumerate(line,1):
        if ch=='(':
            stack.append((i,j,line.strip()))
        elif ch==')':
            if stack:
                stack.pop()
            else:
                print('Unmatched ) at',i,j)
    # print per-line status for debugging (brief)
    print(f"{i:03d}: stack_size={len(stack)} | {line}")

if stack:
    print('\nUnmatched opening parens (top -> bottom):')
    for ln,chpos,txt in stack[-10:]:
        print(f'line {ln} col {chpos}: {txt}')
else:
    print('All parentheses matched')
