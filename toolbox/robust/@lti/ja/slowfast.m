% SLOWFAST 状態空間slow/fastモード分解
%
% [SS_1,SS_2] = SLOWFAST(SS_,CUT)、または、
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H] = SLOWFAST(A,B,C,D,CUT) は、G(s)を
% slowモードGs(s)とfastモードGf(s)に分解します。
%
%                 G(s) = Gs(s) + Gf(s)
%     ここで、
%                 Gs(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                 cut = Gs(s)のモードの数
%                 Gf(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
% "branch"を使って、一般的な状態空間表現に展開できます。



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
