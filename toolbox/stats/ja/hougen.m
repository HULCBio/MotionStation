% HOUGEN   反応運動用の Hougen-Watson モデル
%
% YHAT = HOUGEN(BETA,X) は、反応比の予測値 YHAT をベクトルパラメータ 
% BETA と行列データ X の関数として与えます。BETA は5要素をもち、X は3列を
% 必要とします。
% 
% モデルは、つぎのように表わせます。
% 
%    y = (b1*x2 - x3/b5)./(1+b2*x1+b3*x2+b4*x3)
% 
% 参考文献：
%      [1]  Bates, Douglas, and Watts, Donald, "Nonlinear
%      Regression Analysis and Its Applications", Wiley
%      1988 p. 271-272.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:12:19 $
%   B.A. Jones 1-06-95.
