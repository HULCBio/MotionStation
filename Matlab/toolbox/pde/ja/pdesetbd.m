% PDESETBD は、PDE Tollbox の境界に対する境界条件を設定します。
% 
%     pdesetbd(BOUNDS,TYPE,MODE,COND,COND2,COND3,COND4)
%
% pdesetbd(BOUNDS,TYPE,MODE,COND,COND2) は、境界 BOUNDS を COND と COND2
% で指定されたタイプ TYPE の境界条件に設定します。MODE は、スカラ問題の
% 場合1、システム(2次元)問題の場合2です。
% 
% BOUNDS は、境界条件行列と分解されるリスト内の列番号に対応します。BOU-
% NDS は外側の境界のみを含んでいます。
% 
% (一般的な)Neumann 条件では TYPE = 'neu' で、Dirichlet 条件では TYPE = 
% 'dir'、混合境界条件では TYPE = 'mix' です。
% 
% 注意 : 
% システム(2次元)の場合のみ、混合条件が使用可能です。
% 
% COND, COND2,... は、x と y の関数または曲率の関数で表した境界条件を含
% む文字列です。
% 
%  一般的な Neumann 条件の場合
% 
%     n*(c*grad(u))+q*u = g,
% 
% COND は、q部を含み、 COND2 は、g 部を含みます。
% 
% Dirichlet条件の場合
% 
%        h*u = r,
% 
% COND は、h 部を含み、COND2 は、r 部を含みます。
% 
% 混合条件の場合
% 
%        n*(c*grad(u))+q*u = g; hu = r,
% 
% COND は、q 部を含み、COND2 は、g 部を含み、 COND3 は、h 部を含み、CO-
% ND4 は、r 部を含みます。
% 

%       Copyright 1994-2001 The MathWorks, Inc.
