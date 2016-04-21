% FIXPTBESTEXP  最高精度を与える指数の決定
%
% 値に対する固定小数点表現
% 利用法:
% fixedExponent = FIXPTBESTEXP( RealWorldValue, TotalBits, IsSigned ) また
% は fixedExponent = FIXPTBESTEXP( RealWorldValue, FixPtDataType )
%
% 最高精度(2のべき乗)の固定小数点表現は、式RealWorldValue = StoredInteger
% * 2^fixedExponent に基づきま。ここで、StoredIntegerは指定したサイズと符号付
% き/符号なしステータスをもつ整数です。
%
% 負の固定小数点表現は、小数点の右側のビット数を指定します。
%
% たとえば、fixptbestexp(4/3,16,1) または fixptbestexp(4/3,sfix(16)) は、
% -14 を出力します。これは、符号付き16ビット数が用いられた場合は、最大精度表現
% 1.33333333333333 (base 10)は、小数点の14ビット右に置くことによって得られる
% ことを意味します。表現は、01.01010101010101 (base 2)  =  21845 * 2^-14 =
% 1.33331298828125 (base 10)になります。この表現の精度は、スケーリングを
% 2^-14 または 2^fixptbestexp(4/3,16,1)に設定することによって固定小数点ブロッ
% クで指定されます。
%
% 参考 : SFIX, UFIX, FIXPTBESTPREC


% Copyright 1994-2002 The MathWorks, Inc.
