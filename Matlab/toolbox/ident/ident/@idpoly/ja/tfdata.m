% IDPOLY/TFDATA は、IDPOLY モデルオブジェクトを伝達関数に変換します。
%
% [NUM,DEN] = TFDATA(MODEL) は、モデルオブジェクト MODEL の分子と分母を
% 出力します。NY 出力、NU 入力をもつ伝達関数に対して、NUM と DEN は、NUM
% {I,J}が入力 J から出力 I までの伝達関数を指定する NY 行 NU 列のセル配
% 列です。
% 
% [NUM,DEN,SDNUM,SDDEN] = TFDATA(MODEL) は、分子係数と分母係数の標準偏差
% も出力します。
% 
% MODEL の他のプロパティは、GET を使うか、または、直接的に構造体の参照法
% (たとえば、MODEL.Ts)を使ってアクセスします。
%
% MODEL が時系列(NU = 0)の場合、NY ノイズ源からの応答yが出力されます。
% NY行NY列のそのような伝達関数があります。
%
% 入力をもつシステムに対する(正規化された)ノイズ応答を得るには、
% 
%       [NUM,DEN] = TFDATA(MODEL('noise'))
% 
% を使ってください。
%
% ノイズの偏差の正規化を含むためにオプションを使用して、ノイズ源を
% 測定チャンネルに変換するためには、NOISECNVを使ってください。
% 
% SISO モデル MODEL に対して、シンタックス
% 
%       [NUM,DEN] = TFDATA(MODEL,'v')
% 
% は、セル配列でなく行ベクトルとして、分子と分母を出力します。
%
% 参考： IDMODEL/SSDATA, IDMODEL/ZPKDATA, IDMODEL/POLYDATA,
%        IDMODEL/FREQRESP, NOISECNV.

%   L. Ljung 10-2-90


%   Copyright 1986-2001 The MathWorks, Inc.
