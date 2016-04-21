% NICHOLS   LTIモデルのNichols周波数応答
%
% NICHOLS(SYS) は、LTIモデル SYS(TF, ZPK, SS または FRD いずれかで作成
% された)のNichols線図を描きます。周波数域と点数は自動的に選ばれます。
% 離散時間の周波数の記述の詳細は、BODE を参照してください。
% 
% NICHOLS(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数帯域(ラジアン
% /秒で)に対して Nichols 線図を描きます。
%
% NICHOLS(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を
% 利用して、その点で Nichols 線図が計算されます。対数スケールでの周波数
% ベクトルの作成については、LOGSPACE を参照してください。
%
% NICHOLS(SYS1,SYS2,...,W) は、複数のLTIモデル SYS1,SYS2,... のNichols
% 線図を1つのプロットにします。周波数ベクトル W はオプションです。つぎの
% ようにカラー、ラインスタイル、マーカを各システム毎に指定することができ
% ます。
% 
%   nichols(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = NICHOLS(SYS,W) と [MAG,PHASE,W] = NICHOLS(SYS) は、ゲイン
% と度単位での位相の応答(計算を実行する周波数のベクトルWを設定していない
% 場合、これも含めて)を出力します。画面にプロットは出力しません。SYS が
% NY 出力とNU 入力をもつ場合、MAG と PHASE はサイズ [NY NU LENGTH(W)] 
% の配列で、ここで、MAG(:,:,k) と PHASE(:,:,k) は、周波数 W(k) での応答
% を決めます。
%
% 参考 : BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


%   Authors: P. Gahinet, B. Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
