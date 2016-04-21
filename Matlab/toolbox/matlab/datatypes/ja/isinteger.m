%ISINTEGER 整数データタイプの配列に対して True
% ISINTEGER(A) は、A が整数データタイプの配列の場合、true, そうでない場合、
% false を出力します。
%
% MATLAB の 8 個の整数データタイプは、int8, uint8, int16, uint16,int32, 
% uint32, int64 および uint64 です。
%
% 例題:
% isinteger(int8(3))
% は、int8 は、有効な整数データタイプであるため、true を出力しますが、
% isinteger (3)
% は、定数 3 が、class(3) で示されたように、実際、倍精度であるため、
% false を出力します。
%
% 参考 ISA, ISNUMERIC, ISFLOAT.

%   Copyright 1984-2004 The MathWorks, Inc. 
