% FIXPTBESTEXP  最高精度を与える指数の決定
%
% 値に対する固定小数点表現
% 利用法:
% precision = FIXPTBESTPREC( RealWorldValue, TotalBits, IsSigned ) マタハ
% precision = FIXPTBESTPREC( RealWorldValue, FixPtDataType )
%
% 最高精度(2のべき乗)固定小数点表現は、RealWorldValue = StoredInteger *
% precisionに基づきます。ここで、StoredIntegerは、指定したサイズと符号付き/符
% 号なしステータスをもつ整数で、precisionは2のべき乗に制限されます。
%
% たとえば、fixptbestprec(4/3,8,1) または fixptbestprec(4/3,sfix(8)) は、0.
% 015625 = 2^-6を出力します。これは、符号付き8ビット数が用いられた場合は、最大
% 精度表現1.33333333333333 (base 10) は 85 * 0.015625 = 85 * 2^6 = 01.
% 010101 (base 2) =  1.328125 (base 10)であることを示します。精度は、Fixed
% Pointブロックでスケーリングパラメータとして用いられます。
%
% 参考 : SFIX, UFIX, FIXPTBESTEXP


% Copyright 1994-2002 The MathWorks, Inc.
