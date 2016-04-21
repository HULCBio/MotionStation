% CONDEIG   固有値に関する条件数
% 
% CONDEIG(A) は、A の固有値に対する条件数のベクトルを出力します。これら
% の条件数は、左右の固有ベクトルの間の角度の余弦の逆数です。   
% 
% [V,D,s] = CONDEIG(A) は、[V,D] = EIG(A); s = CONDEIG(A) と等価です。
%
% 条件数が大きいと、A が重複した固有値をもつ行列に近いことを表わします。
%
% 参考：COND.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:43 $
