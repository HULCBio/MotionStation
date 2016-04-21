% ESTIM   推定器ゲインを与えて、推定器を作成
%
% EST = ESTIM(SYS,L) は、状態空間モデル SYS のすべての入力は確率的で、
% すべての入力が観測されるという仮定の基に、モデル SYS の出力と状態に
% ついて、ゲイン L をもつ推定器 EST を求めます。連続系では、 
%          .
%   SYS:   x = Ax + Bw ,   y = Cx + Dw   (ｗ は確率的)
% 
% 結果の推定器は、
%     .
%    x_e  = [A-LC] x_e + Ly
%
%   |y_e| = |C| x_e 
%   |x_e|   |I|
%
% で、x と y の推定値 x_e と y_e を求めます。ESTIM は、離散時間システム
% に適用されたとき、同じように働きます。
%
% EST = ESTIM(SYS,L,SENSORS,KNOWN) は、確定的な入力と確率的な入力の両方
% と測定可能な出力と測定できない出力の両方をもつ、より一般的なプラント 
% SYS を扱います。インデックスベクトル SENSORS と KNOWN は、どの出力 y 
% が測定可能で、どの入力 u が既知であるかを示します。結果の推定器 EST は、
% 推定値 [y_e;x_e] を求めるための入力として、[u;y] を利用します。  
%
% 推定器(オブザーバ)ゲイン L を求めるには、極配置(PLACE 参照)の手法を利
% 用することができます。また、KALMAN または KALMD によって求められる 
% Kalmanフィルタゲインを利用することができます。 
%
% 参考 : PLACE, KALMAN, KALMD, REG, LQGREG, SS.


%   Clay M. Thompson 7-2-90
%   Revised: P. Gahinet 7-30-96
%   Copyright 1986-2002 The MathWorks, Inc. 
