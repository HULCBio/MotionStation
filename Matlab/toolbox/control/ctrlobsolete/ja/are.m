% ARE   代数 Riccati 方程式
%
% X = ARE(A, B, C) は、連続時間 Riccati 方程式
%
%        A'*X + X*A - X*B*X + C = 0
% 
% を解いて、(存在する場合)安定な解を出力します。ここで、B は、対称で、
% 非負の正定行列で、C は対称行列です。
%
% 参考 : RIC, CARE, DARE.


%       M. Wette, ECE Dept., Univ. of California 5-11-87
%       Revised 6-16-87 MW
%               3-16-88 MW
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:27 $
