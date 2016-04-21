% GENPOLY2B   生成多項式 RS の妥当性をチェックし、対応する b を計算
%
% [B,ECODE] = GENPOLY2B(GENPOLY) は、GENPOLY が有効な生成多項式かどうかを
% 指定するガロア列ベクトル GENPOLY に対応する B と ECODE を出力します。
% もし GENPOLY が有効でない場合、B は -1 を出力します。
%
%    ECODE の値の意味:
%    0 : 有効な生成多項式
%    1 : 無効な生成多項式
%    2 : 無効な生成多項式: 生成多項式は最高次の係数が1に等しくない(not monic)
%
% [B,ECODE] = GENPOLY2B(GENPOLY,M,PRIM_POLY) は、通常の列ベクトル GENPOLY 
% を与えます。M は、1シンボル当たりのビット数で、PRIM_POLY は、ガロア体の
% 原始多項式です。


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2003/06/23 04:34:30 $ 
