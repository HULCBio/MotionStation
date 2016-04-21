% GFDIV   ガロア体の元の除算
%
% Q = GFDIV(B, A) は、GF(2) の各元で、B を A で除算します。A と B は
% スカラ、あるいは同じサイズのベクトルか行列です。A と B の各要素は 
% GF(2) の元を表現します。A と B の要素は、0または1です。
% 
% Q = GFDIV(B, A, P) は、GF(P) の各元で、B を A で除算します。ここで、
% P は素数です。A と B の各要素は、GF(P) の元を表現します。A と B の
% 要素は、0 と P-1 の間の整数です。
%
% Q = GFDIV(B, A, FIELD) は、GF(P^M) の各元で、B を A で除算します。
% ここで P は素数で、M は正の整数です。A と B の各要素は、指数形式で 
% GF(P^M) の元を表現します。A と B の要素は、-Inf と P^M-2 の間の整数です。
% FIELD は GF(P^M) の全元をリストした行列で、同じ原始元と関連して並べ
% られています。FIELD は FIELD = GFTUPLE([-1:P^M-2]', M, P); を使って
% 生成することができます。
%
% GF(P) または GF(P^M) の多項式の除算については、GFDECONV を使用して
% ください。
%
% 参考： GFMUL, GFCONV, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:35 $
