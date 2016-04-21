% Nr = rnull(M,tolabs,tolrel)
%
% 行列Mの右零空間を特異値に基づいて計算します。
%
% 特異値S(i)は、絶対許容誤差TOLABS、または、相対許容誤差TOLREL以下のとき
% "zero"と見なされます。すなわち、つぎのようになります。
% 
%        S (i)  <  TOLABS 、または、S (i)  <  TOLREL * S (1)
% 
% ここで、S(1)は、最大特異値です。
%
% TOLABS (TOLREL)は、対応するスレッシュホールド値の大きさの設定を行わな
% いようにするために、0に設定されるべきです。



%  Copyright 1995-2002 The MathWorks, Inc. 
