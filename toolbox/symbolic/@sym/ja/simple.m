% SIMPLE   シンボリック式、または、行列の最も短い表現の検索
% SIMPLE(S) は、S のいくつかの異なる代数的簡略化を試行し、S の表現を短く
% する簡略化を表示し、最も短い表現を出力します。S は、シンボリックオブジ
% ェクトです。S が行列ならば、結果は行列全体が最も短くなる表現です。しか
% し、個々の要素が最も短いとは限りません。
%
% [R, HOW] = SIMPLE(S) は、簡略化の途中結果を表示しません。しかし、最も
% 短い表現と共に、その簡略化の方法を示す文字列が得られます。R は、シンボ
% リックオブジェクトで、HOW は文字列です。
%
% 例題 :
%
%      S                          R                  HOW
%
%      cos(x)^2+sin(x)^2          1                  combine(trig)
%      2*cos(x)^2-sin(x)^2        3*cos(x)^2-1       simplify
%      cos(x)^2-sin(x)^2          cos(2*x)           combine(trig)
%      cos(x)+(-sin(x)^2)^(1/2)   cos(x)+i*sin(x)    radsimp
%      cos(x)+i*sin(x)            exp(i*x)           convert(exp)
%      (x+1)*x*(x-1)              x^3-x              collect(x)
%      x^3+3*x^2+3*x+1            (x+1)^3            factor
%      cos(3*acos(x))             4*x^3-3*x          expand
%
%      syms x y positive
%      log(x) + log(y)            log(x*y)           combine
%
% 参考   SIMPLIFY, FACTOR, EXPAND, COLLECT.



%   Copyright 1993-2002 The MathWorks, Inc.
