% GFPLUS   指標2 のガロア体の元を加算
%
% C = GFPLUS(A, B, FVEC, IVEC) は、GF(2^M) の2つの元 A と B を加算します。
% A, B, C は、指数形式を使った GF(2^M) の元を表現します。つまり、
% alpha^C = alpha^A + alpha^B です。ここで GF(2^M) の原始元は alpha です。
% A と B の要素は -Inf と 2^M-2 の間の整数でなければなりません。全ての
% 負の要素は、alpha^-Inf = 0 を表現します。
%
% A と B はスカラか、またはベクトル、行列を取り得ます。A と B が両方共
% スカラでない場合は、同じサイズでなければなりません。A か B どちらかが
% スカラで、他の一方がベクトルか行列の場合は、スカラ入力は拡張されます。
%
% FVEC と IVEC は長さ 2^M のベクトルです。両方の要素は 0 と 2^M-1 の間の
% 整数です。FVEC は、FVEC がベクトルに簡略化されていること以外は、GFADD 
% で使われる FIELD パラメータと同じ情報を含みます。FVEC と IVEC は、
% つぎの式によって求めることができます。
%   FVEC = GFTUPLE([-1 : 2^M-2]',M) * 2.^[0 : M-1]';
%   IVEC(FVEC+1) = 0 : 2^M-1;
%
% GFPLUS と GFADD の両方は、 GF(2^M) の元を加算しますが、多くの場合、
% GFPLUS の方が高速です。
%    
% 参考 : GFADD, GFSUB.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $   $Date: 2003/06/23 04:36:00 $
