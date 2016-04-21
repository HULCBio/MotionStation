* rlc

V1 n1 0 1
*V2 n2 0 1
*L2 1 2 1u
C3 n2 0 1u
*R4 n2 n1 1k
R5 n2 0 1k
*R6 2 0 1k
D5 n1 n2 Is=1n Vth=0.75

*.AC DEC 100 1K 1G
*.DC V1 0 3 0.2
.END
