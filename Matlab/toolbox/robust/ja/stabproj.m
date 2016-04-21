% STABPROJ  状態空間型の安定/不安定分解
%
% [SS_1,SS_2,M] = STABPROJ(SS_)または
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H,M] = STABPROJ(A,B,C,D)は、
% G(s)を安定部G1(s)と不安定部G2(s)に分解します。
%
%                  G(s):= ss_ = mksys(a,b,c,d);
%                  G1(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                  G2(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
% 通常の状態空間型は、"branch"で求めることができます。



% Copyright 1988-2002 The MathWorks, Inc. 
