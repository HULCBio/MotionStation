% NICHOLS   LTI モデルの Nichols 周波数応答を計算
%
%
% NICHOLS(SYS) は、LTI モデル SYS(TF, ZPK, SS または FRD いずれかで作成
% された)のNichols 線図を描きます。周波数帯域と点数は自動的に選択されます。
% 離散時間の周波数についての注意事項の詳細は、BODE を見てください。
%
% NICHOLS(SYS,{WMIN,WMAX}) は、WMIN から WMAX までの周波数帯域(ラジアン/秒で)
% に対して Nichols 線図を描きます。
%
% NICHOLS(SYS,W) は、ユーザがラジアン/秒で指定した周波数ベクトル W を利用して、
% その点で Nichols 線図が計算されます。対数スケールでの周波数ベクトルを作成
% するためには、LOGSPACE を参照してください。
%
% NICHOLS(SYS1,SYS2,...,W) は、複数の LTI モデル SYS1,SYS2,... の Nichols
% 線図を1つのプロットにします。周波数ベクトル W は、オプションです。
% つぎのようにカラー、ラインスタイル、マーカを各システム毎に指定することが
% できます。 
%   nichols(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = BODE(SYS,W) と [MAG,PHASE,W] = BODE(SYS) は、ゲインと度単位
% での位相の応答(計算を実行する周波数のベクトル W を設定していない場合、これ
% も含めて)を出力します。画面にはプロットは表示されません。SYS がNY 出力と
% NU 入力をもつ場合、MAG と PHASE はサイズ [NY NU LENGTH(W)]の配列で、ここで、
% MAG(:,:,k) と PHASE(:,:,k) は、周波数 W(k) での応答を決めます。
%
% 参考 : BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
