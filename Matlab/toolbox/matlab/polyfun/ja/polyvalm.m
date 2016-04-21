% POLYVALM   引数を行列として多項式を計算
% 
% Y = POLYVAL(P,X) は、P が多項式の係数を要素にもつ N+1 の長さの
% ベクトルのとき、行列引数 X を使って計算された多項式の値です。
% X は、正方行列でなければなりません。
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)*I
%
% 入力 p, X のサポートクラス
%      float: double, single
%
% 参考 POLYVAL, POLYFIT.

%   Copyright 1984-2004 The MathWorks, Inc.