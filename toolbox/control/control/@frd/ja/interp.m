% INTERP   周波数点間でFRDモデルを内挿
%
%
% ISYS = INTERP(SYS,FREQS) は、FRDモデル SYS に含まれる周波数応答データを
% 周波数 FREQS での応答に内挿します。INTERP は、線形内挿を使って、新しい
% 周波数点 FREQS で内挿したデータを含むFRDモデル ISYS を出力します。
%
% 周波数点値 FREQS は、同じ単位で、SYS.FREQUENCY として表現され、SYS の
% 中の最小周波数点と最大周波数点の間に位置します。 すなわち、外挿は
% 行いません。
%
% 参考 : FREQRESP, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
