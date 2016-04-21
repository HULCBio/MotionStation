%LOG1P  log(1+x) の適切な計算
% LOG1P(X) は、1+x の丸めについて補正して、log(1+x) を計算します。
% 小さい x に対し、log1p(x) は、x で近似されますが、log(1+x) はゼロとする
% ことができます。
%
% 参考 LOG, EXPM1.

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2003 The MathWorks, Inc. 
