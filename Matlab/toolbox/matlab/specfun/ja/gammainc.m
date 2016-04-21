% GAMMAINC   不完全ガンマ関数
% 
% Y = GAMMAINC(X,A) は、X と A の対応する要素について、不完全ガンマ関数を
% 実行します。X と A は、同じサイズでなければなりません(または、いずれかが
% スカラでも構いません)。A は非負でなければなりません。
%
% 不完全ガンマ関数は、つぎのように定義されます。 
% 
% gammainc(x,a) = 1 ./ gamma(a) .* t^(a-1) exp(-t)      
%                     dtの0からxまでの積分
%
% 任意の正の a に対して、x が無限大に近付くと、gammainc(x,a) は1に近付きま
% す。x と a が小さければ、gammainc(x,a) ~ =  x^a なので、gammainc(0,0) は
% 1になります。
%
% Y = GAMMAINC(X,A,TAIL)は、Xが非負のとき不完全ガンマ関数の裾を指定します。
% 選択肢は、'lower' (デフォルト)と'upper'です。upper不完全ガンマ関数は、
% つぎのように定義されます。
%   1 - gammainc(x,a).
%
%   ワーニング: Xが負のとき、Yはabs(X) > A+1に対して不正確になる場合があります。

% 参考：GAMMA, GAMMALN, PSI.


%   Copyright 1984-2002 The MathWorks, Inc. 
