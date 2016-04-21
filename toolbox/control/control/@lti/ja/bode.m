% BODE   LTIモデルの Bode 線図を計算、作成
%
% BODE(SYS) は、LTIモデル SYS(TF、ZPK、SS、または、FRD のいずれかで作成
% された)の Bode 線図を描きます。周波数帯域や応答を計算する点数は自動的
% に選択されます。
%
% BODE(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数帯域(ラジアン/秒
% で)に対して、Bode 線図を描きます。
%
% BODE(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を利用し
% て、その点で Bode 線図が計算されます。対数スケールでの周波数ベクトルの
% 作成については、LOGSPACE を参照してください。
%
% BODE(SYS1,SYS2,...,W) は、複数の LTI システム SYS1,SYS2,... の Bode 
% 線図を1つのプロットにします。周波数ベクトル W は、オプションです。つぎの
% ように、カラー、ラインスタイル、マーカを各システム毎に指定することも
% できます。
% 
%   bode(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = BODE(SYS,W) と [MAG,PHASE,W] = BODE(SYS) は、ゲインと度
% 単位での位相の応答(計算を実行する周波数のベクトル W を設定していない場
% 合、これも含めて)を出力します。この場合、画面にプロットは出力しません。
% SYS が、NU 入力 NY 出力の場合、MAG と PHASE は、サイズ [NY NU LENGTH(W)]
% の配列です。ここで、MAG(:,:,k) と PHASE(:,:,k) は、周波数 W(k) での
% 応答です。ゲインを dB で得るには、MAGDB = 20*log10(MAG) と入力して
% ください。
%
% サンプル時間 Ts の離散時間モデルに対して、BODE は単位円を実周波数軸上
% に写像するために変換 Z = exp(j*W*Ts) を利用します。周波数応答は、Nyq-
% uist 周波数 pi/Tz より小さい周波数域でのみプロットされ、Ts が省略され
% た時には、デフォルト値として1(秒)が仮定されます。
%
% 参考 : BODEMAG, NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
