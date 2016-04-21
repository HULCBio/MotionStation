% IDARX/SSDATA は、IDARA モデルの状態空間モデルを出力します。
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
% M は、IDARX モデルオブジェクトです。
% 出力は、つぎの型をした離散時間状態空間行列になります。
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
% は、モデルの不確かさ(標準偏差)dA 等も出力します。



%   Copyright 1986-2001 The MathWorks, Inc.
