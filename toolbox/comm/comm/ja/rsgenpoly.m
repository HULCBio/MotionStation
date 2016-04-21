% RSGENPOLY   リードソロモンコードの生成多項式
%
% GENPOLY = RSGENPOLY(N,K) は、長さN のコードワードと長さK のメッセージ
% をもつリードソロモンコードのデフォルトの生成多項式を出力します。
% コードワードの長さNは、3と16の間のある整数mに対して、形式2^m-1をもつ
% 必要があります。 出力GENPOLY は、生成多項式を降べきの順に並べた
% ガロア体上の係数ベクトルです。デフォルトの生成多項式は、
% (X-alpha)*(X-alpha^2)*...*(X-alpha^(N-K)) です。ここで、
% alpha は、フィールドGF(N+1)に対するデフォルトの原始多項式の根です。
%   
% GENPOLY = RSGENPOLY(N,K,PRIM_POLY) は、PRIM_POLY に、GF(N+1)上に
% alphaの根をもつGF(N+1)をもつ原始多項式を指定することを除いて、
% 上のシンタックスと同じです。
% PRIM_POLY は、原始多項式の係数を、 降べきの順にバイナリで表現した
% 整数です。デフォルトの原始多項式を使用するために、PRIM_POLYを [] に
% 設定します。
%   
% GENPOLY = RSGENPOLY(N,K,PRIM_POLY,B) は、生成多項式 
% (X-alpha^B)*(X-alpha^(B+1))*...*(X-alpha^(B+N-K-1)) を出力します。
% ここで、B は整数であり、alpha はPRIM_POLY の根です。
%   
% [GENPOLY,T] = RSGENPOLY(...) は、コードのエラー修正能力 T
% を出力します。
%
% 例題:
%      g  = rsgenpoly(7,3)       %  デフォルトの生成多項式
%      g2 = rsgenpoly(7,3,13)    %  原始多項式、D^3+D^2+1に関する
%                                %  デフォルトの生成多項式
%                                %   
%      g3 = rsgenpoly(7,3,[],4)  %  b=4を使用
%   
% 参考 GF, RSENC, RSDEC.


%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2.4.1 $  $Date: 2003/06/23 04:35:16 $ 
