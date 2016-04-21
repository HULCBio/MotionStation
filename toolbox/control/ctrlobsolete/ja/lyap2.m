% LYAP2   固有値分解を使ったLyapunov方程式
% 
% X = LYAP2(A,C) は、つぎのような特別な型をした Lyapunov 行列方程式を
% 解きます。
%
%    A*X + X*A' = -C
%
% X = LYAP2(A,B,C) は、つぎのような一般的な Lyapunov 行列方程式を解きます。
%
%    A*X + X*B = -C
%
% LYAP2 は、A または B のいずれかが重根をもつ場合を除いて、LYAP よりも
% 一般的に精度が高く、高速に解くことができます。
%
% 参考 : DLYAP.


%   A.C.W. Grace  10-25-89
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:11 $
