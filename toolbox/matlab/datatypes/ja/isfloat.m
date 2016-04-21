%ISFLOAT 単精度および倍精度の浮動小数点配列に対して True
% ISFLOAT(A) は、A が浮動小数点配列の場合、true, そうでない場合、false 
% を出力します。
%
% MATLAB での浮動小数点データタイプは、単精度および倍精度に限られます。
%
% 例題:
%   isfloat(single(pi))
%   は、single が浮動小数点データタイプであるため、true を出力しますが、
%   isfloat(int8(3))
%   は、int8 が浮動小数点データタイプではないため、false を出力します。
%
% 参考 ISA, DOUBLE, SINGLE, ISNUMERIC, ISINTEGER.

%   Copyright 1984-2004 The MathWorks, Inc. 
