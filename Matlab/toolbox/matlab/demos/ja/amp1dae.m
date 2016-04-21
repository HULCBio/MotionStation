% AMP1DAE  電気回路のスティッフな微分代数方程式(DAE)
%
% AMP1DAE は、正則でない質量行列 M*u' = f(t,u) を使った問題として表わ
% されるスティッフな微分代数方程式(DAE)システムの解のデモを実行します。
%   
% これは、E. Hairer and G. Wanner、Solving Ordinary Differential Equat-
% ions II Stiff and Differential-Algebraic Problems、2nd ed.、Springer、
% Berlin,1996の377 ページにあるトランジスタ増幅問題の1つです。この問題は、
% 半明示的な形式で簡単に書くことができますが、非対角の質量行列 M*u' = 
% f(t,u)の形式では、問題が生じます。ここではオリジナルの非対角型で解きま
% す。Hairer and WannerのFig. 1.4は、[0 0.2]での解を示していますが、計算
% に時間がかからず、解の性質が短い区間で明らかであるため、ここでは、
% [0 0.05]で計算します。
%   
% 参考：ODE23T, ODE15S, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-6-98
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $
