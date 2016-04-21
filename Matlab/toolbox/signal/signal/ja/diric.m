% DIRIC  Dirichlet 関数または周期的な sinc 関数
%
% Y = DIRIC(X,N)は、Xの要素のDirichlet関数を要素とする X と同じ大きさの
% 行列を出力します。正の整数Nは、0から2*piまでの区間で等間隔で分布する計
% 算する点数です。
% 
% Dirichlet 関数は、以下のように定義されます。
%
%    d(X) = sin(N*X/2)./(N*sin(X/2))
%
%  Xが 2*piの整数倍であれば、出力Yは 1 または、-1 の値になります。



%   Copyright 1988-2002 The MathWorks, Inc.
