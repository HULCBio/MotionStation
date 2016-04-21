% COND   逆行列の精度の尺度を与える行列の条件数
% 
% COND(X) は、2-ノルム条件数(Xの最大の特異値と最小の特異値の比)を出
% 力します。条件数が大きいと、特異行列に近いことを示します。
%
% COND(X,P) は、P-ノルムの行列 X の条件数を出力します。
%
% NORM(X,P) * NORM(INV(X),P). 
%
% ここで、P = 1、2、inf、'fro' です。
%
% 参考：RCOND, CONDEST, CONDEIG, NORM, NORMEST.


%   Copyright 1984-2003 The MathWorks, Inc. 

