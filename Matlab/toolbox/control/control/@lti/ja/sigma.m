% SIGMA   LTIモデルの特異値プロット
%
% SIGMA(SYS) は、LTI モデル SYS(TF,ZPK,SS,FRD によって作成された)の周波数
% 応答における特異値(SV)プロットを行います。周波数帯域と点数は自動的に
% 選択されます。離散時間での注意事項についての詳細は、BODE を参照して
% ください。
%
% SIGMA(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数(ラジアン/秒)に
% おける SV プロットを描きます。
%
% SIGMA(SYS,W) は、ユーザがラジアン/秒で指定した周波数のベクトル W を
% 利用し、その点で周波数応答を計算します。対数スケールでの周波数ベクトル
% を作成するためには、LOGSPACE を参照してください。
%
% SIGMA(SYS,W,TYPE)、または、SIGMA(SYS,[],TYPE) は、つぎのように TYPE の
% 値に応じて変更した SV プロットを描きます。
% 
%       TYPE = 1     -->     inv(SYS)のSV  
%       TYPE = 2     -->     I + SYSのSV
%       TYPE = 3     -->     I + inv(SYS)のSV 
% 
% この書式を用いるときには、SYS は正方行列でなければいけません。
%
% SIGMA(SYS1,SYS2,...,W,TYPE) は、いくつかのLTIモデル SYS1,SYS2,... の
% SV 応答を1つのプロットに描きます。引数 W と TYPE は、オプションです。
% sigma(sys1,'r',sys2,'y--',sys3,'gx') のように、カラー、ラインスタイル
% マーカを指定することもできます。
% 
% SV = SIGMA(SYS,W) と [SV,W] = SIGMA(SYS) は、周波数応答の特異値 SV を
% 出力します(計算を実行する周波数のベクトル W を設定していない場合、
% これも含めて) 画面にプロットは描きません。行列 SV は、length(W) の列数
% をもち、SV(:,k) が周波数 W(k)での特異値を与えます。
%
% Robust Control Toolboxの書式の詳細は、HELP RSIGMA とタイプしてください。
%
% 参考 : BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, LTIMODELS.


%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%       Revised P. Gahinet 5-7-96
%       Revised A. DiVergilio 6-16-00
%       Revised K. Subbarao 10-11-01
%	Copyright 1986-2002 The MathWorks, Inc. 
