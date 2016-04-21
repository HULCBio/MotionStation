% BODE   LTI モデルの Bode 線図を計算、作成
%
%
% BODE(SYS) は、LTI モデル SYS(TF、ZPK、SS、または、FRD のいずれかで作成された)
% の Bode 線図を描きます。周波数帯域や応答を計算する点数は自動的に選択されま
% す。
%
% BODE(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数帯域(ラジアン/秒で)
% に対して、Bode 線図を描きます。
%
% BODE(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を利用して、
% その点で Bode 線図が計算されます。対数スケールでの周波数ベクトルの作成に
% ついては、LOGSPACE を参照してください。
%
% BODE(SYS1,SYS2,...,W) は、複数の LTI システム SYS1,SYS2,... の Bode 線図を
% 1つのプロットにします。周波数ベクトル W は、オプションです。
% つぎのように、カラー、ラインスタイル、マーカを各システム毎に指定することもでき
% ます。 
%
% bode(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = BODE(SYS,W) と [MAG,PHASE,W] = BODE(SYS) は、ゲインと度単位
% での位相の応答(計算を実行する周波数のベクトル W を設定していない場合、これ
% も含めて)を出力します。この場合、画面にプロットは出力しません。SYS が、NU 入
% 力 NY 出力の場合、MAG と PHASE は、サイズ [NY NU LENGTH (W)]の配列です。 こ
% こで、MAG(:,:,k) と PHASE(:,:,k) は、周波数 W(k) での応答です。
% ゲインを dB で得るには、MAGDB = 20*log10(MAG) と入力してください。
%
% サンプル時間 Ts の離散時間モデルに対して、BODE は単位円を実周波数軸上に
% 写像するために変換 Z = exp(j*W*Ts) を利用します。周波数応答は、Nyquist周波数
% pi/Tz より小さい周波数域でのみプロットされ、Ts が省略された時には、デフォル
% ト値として1(秒)が仮定されます。
%
% 参考 : BODEMAG, NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
