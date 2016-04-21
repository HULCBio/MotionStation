% COMPREAL   SIMO 伝達関数の Companion 実現
%
% [A,B,C,D] = COMPREAL(NUM,DEN) は、共通の分母 DEN(行ベクトル)をもつ 
% SIMO 伝達関数 NUM/DEN の状態空間実現 (A,B,C,D) を作成します。分子 
% NUM は、P 行 L 列の行列で、P は出力数、L = length(DEN)です。
%
% 参考 : TF/SS, COMPBAL.


%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:29 $
