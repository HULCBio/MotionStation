% EXPINT   指数積分関数
% 
% Y = EXPINT(X) は、X の各要素に対する指数積分関数です。指数積分は、
% つぎのように定義されます。
%
% EXPINT(x) =  x > 0 について、(exp(-t)/t) dtのXからInfまでの積分
% 
% 解析的連続性のため、EXPINT は、負の実数軸と交差する複素平面上の一価
% 関数です。
%
% 指数積分関数のもう1つの一般的な定義は、正の X に対して、-Infから X 
% までの (exp(t)/t)dtのCauchyの主値積分です。これは、Ei(x) と表わされます。
% EXPINT(x) と Ei(x) の関係は、つぎのようになります。
%
% 0より大きい実数の x に対して、EXPINT(-x+i*0) = -Ei(x) - i*pi
% 0より大きい実数の x に対して、Ei(x) = REAL(-EXPINT(-x))


%   D. L. Chen 9-29-92, CBM 6-28-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:12 $
