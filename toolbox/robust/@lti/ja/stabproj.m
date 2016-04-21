% STABPROJ 状態空間 安定/不安定モード分解
%
% [SS_1,SS_2,M] = STABPROJ(SS_)、または、
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H,M] = STABPROJ(A,B,C,D) は、G(s)を安
% 定モードG1(s)と不安定モードG2(2)に分解します。ここで、
%
%                  G(s):= ss_ = mksys(a,b,c,d);
%                  G1(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                  G2(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
% "branch"を使って、一般的な状態空間表現に展開できます。



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
