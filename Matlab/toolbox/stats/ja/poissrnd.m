% POISSRND   Poisson 分布のランダム行列
%
% R = POISSRND(LAMBDA) は、パラメータ LAMBDA をもつ Poisson 分布から
% 抽出した乱数行列を出力します。
% 
% R の大きさは、LAMBDA の大きさです。また、R = POISSRND(LAMBDA,M,N) は、
% M行N列の行列を出力します。
% 
% POISSRND は、LAMBDA の小さな値に対して、待ち時間法(waiting time method)
% を、LAMBDA の大きな値に対して、Ahrens と Dieter の手法を使います。


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:54 $
