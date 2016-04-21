% ABCDCHK   A,B,C,D行列の次元の整合性のチェック
% 
% ERROR(ABCDCHK(A,B,C,D)) は、線形時不変システムのモデルに対して、A,B,C,D
% の次元に整合性があるかをチェックします。非ゼロの次元に整合性がないと、
% エラーになります。
%
% [MSG,A,B,C,D] = ABCDCHK(A,B,C,D) は、任意の0行0列の空行列の次元を、
% 他の行列と整合性があるように変更します。


%   Copyright 1984-2004 The MathWorks, Inc.