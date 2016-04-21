% BETAINV   ベータ分布の逆累積分布関数(cdf)
%
% X = BETAINV(P,A,B) は、パラメータ A と B をもつ P の値でのベータ累積
% 分布関数の逆関数を出力します。
%
% X の大きさは、入力引数と同じ大きさです。スカラの入力は、他の入力
% と同じ大きさの定数行列として機能します。 
% 
% BETAINV は、解の収束計算に Newton 法を使用します。


%   B.A. Jones 1-12-93
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:09:05 $
