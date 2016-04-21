% SIGMA   LTI モデルの特異値プロット
%
%
% SIGMA(SYS) は、LTI モデル SYS(TF,ZPK,SS,FRD によって作成された)の周波数
% 応答における特異値(SV)プロットを行います。周波数帯域と点数は自動的に
% 選択されます。離散時間での注意事項についての詳細は、BODE を参照して
% ください。
%
% SIGMA(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数(ラジアン/秒による)
% における SV プロットを描きます。
%
% SIGMA(SYS,W) は、ユーザがラジアン/秒で指定した周波数のベクトル W を利用し、
% その点で周波数応答を計算します。対数スケールでの周波数ベクトルを作成する
% ためには、LOGSPACE を参照してください。
%
% SIGMA(SYS,W,TYPE)、または、SIGMA(SYS,[],TYPE) は、つぎのように TYPEの
% 値に応じて変更した SV プロットを描きます。 
%   TYPE = 1     -->     inv(SYS)の SV 
%   TYPE = 2     -->     I + SYSの SV 
%   TYPE = 3     -->     I + inv(SYS)の SV 
% この書式を用いるときには、SYS は正方行列でなければいけません。
%
% SIGMA(SYS1,SYS2,...,W,TYPE) は、いくつかの LTI モデル SYS1,SYS2,... の
% SV 応答を1つのプロットに描きます。引数 W と TYPE は、オプションです。
% sigma(sys1,'r',sys2,'y--',sys3,'gx') のように、カラー、ラインスタイル
% マーカを指定することもできます。
%
% SV = SIGMA(SYS,W) と [SV,W] = SIGMA(SYS) は、周波数応答の特異値 SV を
% 出力します(計算を実行する周波数のベクトル W を設定していない場合、これも
% 含めます) 。画面にはプロットは表示されません。行列 SV は、length(W) の
% 列数をもち、SV(:,k) が周波数 W(k)での特異値を(降順に)与えます。
%
% Robust Control Toolbox の書式の詳細は、HELP RSIGMA とタイプしてください。
%
% 参考 : BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
