% BATONODE   バトンの挙動のシミュレーション
% 
% BATONODEは、時間依存および状態依存の質量行列問題を解きます。この例題は、
% D.A. Wells、Theory and Problems of Lagrangian Dynamics、McGraw-Hill、
% 1967のExample 4.3Aに基づいています。質量行列を使った多くの問題が公式化
% されています。バトンは、長さLの軽い棒に堅く固定された質量m1およびm2の2
% つの粒子としてモデル化されています。その挙動は、重力の作用の下で垂直の
% xy平面内で起こります。1つ目の粒子の座標が(X,Y)で、水平方向と棒の角度が
% thetaの場合、Lagrange方程式は、未知のthetaに依存する質量行列を導きます。
% ここで、変数yは、y(1) = X、y(2)= X'、y(3) = Y、y(4) = Y'、y(5) = theta、
% y(6) = theta'です。
%   
% 参考：ODE45, ODE113, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-6-98
%   Copyright 1984-2002 The MathWorks, Inc. 
