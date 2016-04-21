% VDPODE   (大きいmuに対してスティッフな)van der Pol式のパラメータ化
% 
% MUが1000のとき、方程式は振動を緩和し、問題は非常にスティッフになります。
% このリミットサイクルには、解の成分がゆっくりと変化し、問題が非常にステ
% ィッフな領域と、スティッフでない(準不連続性)非常に激しい変化のある領域
% が交互にあります。初期条件は、初期ステップサイズの選択に対するテストの
% ために、ゆっくり変化する領域に近くなっています。
%   
% サブ関数 J(T, Y, MU) は、(T,Y) で解析的に計算した Jacobian 行列 dF/dY 
% を出力します。デフォルトで、ODE Suite のスティフなソルバは、数値的に 
% Jacobian 行列を近似します。しかし、ODE Solver プロパティ Jacobian は、
% 関数 ODESET を使って、@vdpJac に設定され、ソルバーは、dF/dy を得るため
% に関数をコールします。解析的な Jacobian をもつソルバーが、必ずしも用意
% されなくても構いませんが、積分の信頼性と効率を高めます。
% 
%   L. F. Shampine, Evaluation of a test set for stiff ODE solvers, ACM
%   Trans. Math. Soft., 7 (1981) pp. 409-420.
%   
% 参考：ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-23-94, 4-19-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:49:36 $

