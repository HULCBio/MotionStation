% INV   LTIモデルの逆システム
%
%
% ISYS = INV(SYS) は、つぎのような逆システム ISYS を計算します。
%
%  y = SYS * u   <---->   u = ISYS * y
%
% LTIモデル SYS は、入力と出力の数が同じでなければいけません。
%
% LTIモデルの配列に対して、INV は各モデル毎に実行されます。
%
% 参考 : MLDIVIDE, MRDIVIDE, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
