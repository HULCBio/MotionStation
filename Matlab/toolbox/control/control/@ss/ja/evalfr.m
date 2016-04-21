% EVALFR   単一(複素)周波数での周波数応答を計算
%
% FRESP = EVALFR(SYS,X) は、連続時間または離散時間LTIモデル SYS の伝達
% 関数を複素数 S = X、または、Z = X で評価します。状態空間モデルに対して、
% 結果は、つぎのようになります。
%                                -1
%    FRESP =  D + C * (X * E - A)  * B  
%
% EVALFR は、FREQRESP の簡易版で、単一点での応答を迅速に求めることが
% できます。複数の周波数に対する周波数応答を求めるには、FREQRESP を
% 利用します。
%
% 参考 : FREQRESP, BODE, SIGMA, LTIMODELS.


%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2002 The MathWorks, Inc. 
