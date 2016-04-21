% RIGIDODE   外力のない剛体のEuler方程式
% 
% Kroghにより提示された、ノンスティッフなソルバに対する標準的なテスト問
% 題。解析解は、MATLABでアクセス可能なヤコビアン楕円関数です。ここでの区
% 間は、約1.5です。これは、下記の文献 Shampine and Gordenの243ページにプ
% ロットされている区間です。
%   
% L. F. Shampine and M. K. Gordon, Computer Solution of Ordinary
% Differential Equations, W.H. Freeman & Co., 1975.
%   
% 参考：ODE45, ODE23, ODE113, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-23-94, 4-19-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:49:22 $

