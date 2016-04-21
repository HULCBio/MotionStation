% ROT90   行列を90°回転
% 
% ROT90(A)は、行列Aを反時計回りに90°回転します。ROT90(A,K)は、K = +-1,+-2,...
% のとき、行列AをK*90°回転します。
%
% 例題
%       A = [1 2 3      B = rot90(A) = [ 3 6
%            4 5 6 ]                     2 5
%                                        1 4 ]
%
% 参考：FLIPUD, FLIPLR, FLIPDIM.


%   From John de Pillis 19 June 1985
%   Modified 12-19-91, LS.
%   Copyright 1984-2003 The MathWorks, Inc. 
