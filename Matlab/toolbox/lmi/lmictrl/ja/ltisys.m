% sys = ltisys(a,b,c,d,e)
% sys = ltisys('tf',n,d)
%
% LTIシステムの状態空間実現(A,B,C,D,E)をSYSTEM行列として格納します。
%
%                       | A+j(E-I)   B   na  |
%             SYS  =    |    C       D    0  |
%                       |    0       0  -Inf |
%
% ここで、na = size(A,1)です。行列AからEは実数です。省略すると、DとEは、
% デフォルト値D=0とE=Iに設定されます。Eに対する値0と1は、E=0とE=Iと解釈
% されます。
%
% SYS = LTISYS(A)とSYS = LTISYS(A,E)は、自由系を設定します。
% 
%               dx/dt = A x     と   E dx/dt = A x 
%
% SISOシステムは、伝達関数表現N(s)/D(s)によっても設定できます。シンタッ
% クスは、SYS = LTISYS('tf',N,D)で、ここで、NとDは、多項式N(s)とD(s)のベ
% クトル表現です。
%
% 参考：    LTISS, LTITF, SINFO.



%  Copyright 1995-2002 The MathWorks, Inc. 
