% POISSINV   Poisson 分布の逆累積分布関数(cdf)
%
% X = POISSINV(P,LAMBDA) は、パラメータ LAMBDA をもつ Poisson 累積分布
% 関数の逆関数を計算します。Poisson 分布は離散なので、POISSINV は、値 X で
%  POISSON 累積分布関数値が P に等しいか、それ以上である最小の整数 X を
% 出力します。
% 
% X の大きさは、P と LAMBDA と同じ大きさです。スカラの入力は、他の入力
% と同じ大きさの定数行列として機能します。


%   B.A. Jones 1-15-93
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:49 $
