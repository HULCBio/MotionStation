%ISNUMERIC 数値配列に対して True
% ISNUMERIC(A) は、A が数値配列である場合、true を出力し、そうでない場合、
% false を出力します。
%
% たとえば、整数および浮動小数 (単精度、倍精度) 配列は、数値ですが、
% 論理値、文字列、セル配列、構造体配列はそうではありません。
%
% 例題:
%   isnumeric(pi)
%   は、pi がクラス double であるため、true を返しますが、
%   isnumeric(true)
%   は、true が論理値のクラスであるため、false を出力します。
%
% 参考 ISA, DOUBLE, SINGLE, ISFLOAT, ISINTEGER, ISSPARSE, ISLOGICAL, ISCHAR.

%   Copyright 1984-2004 The MathWorks, Inc. 
