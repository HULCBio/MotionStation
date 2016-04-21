% DRIC   離散の Riccati 方程式の残差の計算
%
% [Kerr,Serr] = DRIC(A,B,Q,R,K,S) は、離散 Riccati 方程式の解の誤差を
% 計算します。Kerr は、ゲイン行列の中の誤差で、Serr は、Riccati 方程式の
% 中の残差誤差です。
%                   -1                                     -1
%   Kerr = K-(R+B'SB)  B'SA;  Serr = S - A'SA + A'SB(R+B'SB)  BS'A - Q
%
% 参考 : RIC, DLQE, DLQR.


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:55 $
