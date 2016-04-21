% HADAMARD   Hadamard行列
% 
% HADAMARD(N)は、N次のHadamard行列で、すなわち、H'*H = N*EYE(N)のような、
% 要素が1と-1の行列Hです。N > 2のとき、N行N列のHadamard行列は、REM(N,4) 
% = 0の場合のみに存在します。この関数は、N、N/12、または、N/20が、2のベ
% キ乗の場合のみを取り扱います。


%   Author: N.J. Higham 11-14-91.  Revised by CBM, 6/24/92.
%   Copyright 1984-2003 The MathWorks, Inc. 
