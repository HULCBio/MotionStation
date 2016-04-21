% NYQUIST   LTIモデルのNyquist周波数応答
%
% NYQUIST(SYS) は、LTIモデル(TF, ZPK, SS または FRD のいずれかで作成さ
% れた) SYS のNyquist線図をプロットします。周波数帯域と点数は、自動的に
% 選択されます。離散時間の周波数についての注意事項の詳細は、BODE を見て
% ください。
%
% NYQUIST(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数域(ラジアン/秒
% で)に対して、Nyquist 線図をプロットします。
%
% NYQUIST(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を
% 利用して、その点で Nyquist 線図が計算されます。対数スケールの周波数
% ベクトルを作成するには、LOGSPACE を見てください。 
%
% NYQUIST(SYS1,SYS2,...,W) は、複数のLTIモデル SYS1,SYS2,... を1つの
% プロットにします。周波数ベクトル W は、オプションです。つぎのように、
% カラー、ラインスタイル、マーカを設定することもできます。
%
%   nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
% [RE,IM] = NYQUIST(SYS,W) と [RE,IM,W] = NYQUIST(SYS) は、周波数応答の
% 実部 RE と虚部 IM を出力し(計算を行する周波数のベクトル W を設定して
% いない場合、これも含めて)、画面にプロットは描きません。SYS が NY 出力 
% と NU 入力をもつ場合、RE とIM は、サイズ [NY NU LENGTH(W)] の配列に
% なります。ここで、周波数 W(k) での応答は RE(:,:,k)+j*IM(:,:,k) です。
%
% 参考 : BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


%   Authors: P. Gahinet 6-21-96
%   Revised: A. DiVergilio, 6-16-00
%   Copyright 1986-2002 The MathWorks, Inc. 
