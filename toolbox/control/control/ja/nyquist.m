% NYQUIST   LTI モデルのNyquist 周波数応答を計算
%
%
% NYQUIST(SYS) は、LTI モデル(TF, ZPK, SS または FRD のいずれかで作成された)
% SYS の Nyquist 線図をプロットします。周波数帯域と点数は自動的に選択されま
% す。離散時間の周波数についての注意事項の詳細は、BODE を見てください。
%
% NYQUIST(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数域(ラジアン/秒で)
% に対して、Nyquist 線図をプロットします。
%
% NYQUIST(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を利用して、
% その点で Nyquist 線図が計算されます。対数スケールでの周波数ベクトルを作成す
% るためには、LOGSPACE を参照してください。
%
% NYQUIST(SYS1,SYS2,...,W) は、複数の LTI モデル SYS1,SYS2,... を1つの
% プロットにします。周波数ベクトル W は、オプションです。
% つぎのように、カラー、ラインスタイル、マーカを設定することもできます。
%   nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
% [RE,IM] = NYQUIST(SYS,W) と [RE,IM,W] = NYQUIST(SYS) は、周波数応答の実部
% RE と虚部 IM を出力し(計算を行する周波数のベクトル W を設定していない場合、
% これも含めます)。画面にはプロットは表示されません。SYS が NY 出力とNU 入力
% をもつ場合、RE とIM は、サイズ [NY NU LENGTH(W)] の配列になります。 ここで、
% 周波数 W(k) での応答は RE(:,:,k)+j*IM(:,:,k) です。
%
% 参考 : BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
