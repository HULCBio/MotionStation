[b1,w1]=ncrule(1);
[b2,w2]=ncrule(2);
[b3,w3]=ncrule(3);
[b4,w4]=ncrule(4);
[b5,w5]=ncrule(5);
[b6,w6]=ncrule(6);
[b7,w7]=ncrule(7);
[b8,w8]=ncrule(8);

f=gquad('sin',0,pi,1,b1,w1), correct_ans=2
f=gquad('sin',0,pi,1,b2,w2), correct_ans=2
f=gquad('sin',0,pi,1,b3,w3), correct_ans=2
f=gquad('sin',0,pi,1,b4,w4), correct_ans=2
f=gquad('sin',0,pi,1,b5,w5), correct_ans=2
f=gquad('sin',0,pi,1,b6,w6), correct_ans=2
f=gquad('sin',0,pi,1,b7,w7), correct_ans=2
f=gquad('sin',0,pi,1,b8,w8), correct_ans=2

f=gquad('fxpow',0,2,1,b1,w1,1), correct_ans=2
f=gquad('fxpow',0,2,1,b1,w1,2), correct_ans=8/3
f=gquad('fxpow',0,2,1,b1,w1,3), correct_ans=4

f=gquad('fxpow',0,2,1,b2,w2,2), correct_ans=8/3
f=gquad('fxpow',0,2,1,b2,w2,3), correct_ans=4
f=gquad('fxpow',0,2,1,b2,w2,4), correct_ans=32/5

f=gquad('fxpow',0,2,1,b3,w3,3), correct_ans=4
f=gquad('fxpow',0,2,1,b3,w3,4), correct_ans=32/5
f=gquad('fxpow',0,2,1,b3,w3,5), correct_ans=32/3

f=gquad('fxpow',0,2,1,b4,w4,4), correct_ans=32/5
f=gquad('fxpow',0,2,1,b4,w4,5), correct_ans=32/3
f=gquad('fxpow',0,2,1,b4,w4,6), correct_ans=128/7

f=gquad('fxpow',0,2,1,b5,w5,5),correct_ans=32/3
f=gquad('fxpow',0,2,1,b5,w5,6),correct_ans=128/7

f=gquad('fxpow',0,2,1,b6,w6,6),correct_ans=128/7
f=gquad('fxpow',0,2,1,b6,w6,7),correct_ans=32
f=gquad('fxpow',0,2,1,b6,w6,8),correct_ans=512/9

f=gquad('fxpow',0,2,1,b7,w7,7),correct_ans=32
f=gquad('fxpow',0,2,1,b7,w7,8),correct_ans=512/9

f=gquad('fxpow',0,2,1,b8,w8,8),correct_ans=512/9
f=gquad('fxpow',0,2,1,b8,w8,9),correct_ans=512/5
f=gquad('fxpow',0,2,1,b8,w8,10),correct_ans=2048/11
