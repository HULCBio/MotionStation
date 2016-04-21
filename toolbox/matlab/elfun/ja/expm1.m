%EXPM1  exp(x)-1 の適切な計算
% EXPM1(X) は、exp(x) の丸めについて補正して exp(x)-1 を計算します。
% 小さい x に対し、expm1(x) は、x で近似されますが、exp(x)-1 はゼロと
% することができます。
%
% (行列指数のデモの関数n EXPM1 は、現在 EXPMDEMO1 になっています。)
%
% 参考 EXP, LOG1P, EXPMDEMO1.

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2003 The MathWorks, Inc. 
