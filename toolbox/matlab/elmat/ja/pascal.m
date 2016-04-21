% PASCAL   Pascal行列
% 
% PASCAL(N)は、N次のPascal行列を出力します。Pascal行列は、Pascalの三角形
% から得られる整数要素をもつ対称な正定行列です。逆行列の要素は、整数です。
%
% PASCAL(N,1)は、Pascal行列の下三角Cholesky分解(列の符号まで)を出力しま
% す。この行列と逆行列が等しいことは偶然です。
%
% PASCAL(N,2)はPASCAL(N,1)を回転し、N が偶数のとき符号を反転します。
% これは、単位行列の立方根です。


%   Nicholas J. Higham, Dec 1999.
%   Author: N.J. Higham 6-23-89
%   Copyright 1984-2003 The MathWorks, Inc. 
