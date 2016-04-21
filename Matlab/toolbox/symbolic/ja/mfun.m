% MFUN   Maple関数の数値評価
% MFUN('fun', p1, p2, ..., pk) は、'fun' が Maple の関数名で、p が funs 
% のパラメータに対応する数値量です。最後に指定するパラメータには、行列を
% 与えることができます。その他のすべてのパラメータは、Maple 関数で指定さ
% れたタイプでなければなりません。MFUN は、指定したパラメータを使って 
% 'fun' を数値的に評価し、MATLAB 倍精度数値を出力します。'fun' 内の特異
% 点は、NaN として出力されます。
%
% 例題:
%      x = 0:0.1:5.0;
%      y = mfun('FresnelC',x)
%
% MFUN は、Student Edition では使用できません。
%
% 参考： MFUNLIST, MHELP.



%   Copyright 1993-2002 The MathWorks, Inc. 
