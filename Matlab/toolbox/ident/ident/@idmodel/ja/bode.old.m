% IDSS/BODE は、IDSS モデルの Bode 周波数応答を計算します。
%
% BODE(SYS) は、LTI モデル SYS(TF, ZPK, SS, FRD のいずれか)の Bode 線図を
% 描きます。周波数レンジと点数は、自動的に選択されます。
%
% BODE(SYS,{WMIN,WMAX}) は、WMIN と WMAX の間の周波数(rad/sec 単位)に対し
% て、Bode 線図を描きます。
%
% BODE(SYS,W) は、Bode 応答が計算される周波数点を要素とするベクトル W を
% 設定します。対数的に等間隔の周波数ベクトルを作成するには、LOGSPACE を参
% 照してください。
%
% BODE(SYS,SD) は、計算した BODE 線図に、標準偏差の SD 倍で示される信頼区
% 間を表示します。ここで、SD は正のスカラです。
%
% BODE(SYS1,SYS2,...,W,SD) は、単一プロット上に複数の LTI モデル SYS1,
% SYS2,...の Bode 応答をプロットします。周波数ベクトル W は、オプションで
% す。また、つぎのようにして、各システムにカラー、ラインスタイル、マーカ
% を設定することができます。
% 
%      bode(sys1,'r',sys2,'y--',sys3,'gx').
%
% [MAG,PHASE] = BODE(SYS,W) と [MAG,PHASE,W] = BODE(SYS) は、ゲイン応答と
% 度単位の位相応答を出力します。ここで、スクリーン上にプロット表示はあり
% ません。SYS が NY 出力、NU 入力の場合、MAG と PHASE は、サイズ [NY NU 
% LENGTH(W)] の配列になります。MAG(:,:,k) と PHASE(:,:,k) は、周波数 W(k)
% での応答を決定します。デシベル単位でゲインを決定するには、MAGDB = 20*
% log10(MAG) と入力します。
%
% サンプル時間 Ts をもつ離散時間モデルに対して、BODE は、単位円を実周波数
% 軸に投影するために、変換 Z = exp(j*W*Ts) を使います。周波数応答は、Ny-
% quist 周波数 pi/Ts より低いものについてのみプロットします。そして、Ts 
% が設定されていない場合に、デフォルト値1(秒)が使われます。
%
% 参考： NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

% $Revision: 1.2 $ $Date: 2001/03/01 22:54:42 $
%   Copyright 1986-2001 The MathWorks, Inc.
