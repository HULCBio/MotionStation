% RIC   Riccati 方程式の解の残差を計算
%
% [Kerr,Serr] = RIC(A,B,Q,R,K,S) は、Riccati 方程式の解の中の誤差を計算
% します。Kerr は、ゲイン行列の中の誤差、Serr は、Riccati 方程式の中の
% 残差誤差です。
%
%              -1                           -1
%    Kerr = K-R  B'S;  Serr = SA + A'S - SBR  B'S + Q
%
% [Kerr,Serr] = RIC(A,B,Q,R,K,S,N) は、クロス重み付きの項を使ったRiccati
% 方程式の解の中の誤差を計算します。
%
%           -1                                    -1
% Kerr = K-R  (N'+B'S);  Serr = SA + A'S - (SB+N)R  (N'+B'S) + Q
%
% 参考 : DRIC, ARE, LQE, LQR.


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:21 $
