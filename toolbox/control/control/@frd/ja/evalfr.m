% EVALFR   単一(複素)周波数での周波数応答
%
%
% FRESP = EVALFR(SYS,X) は、連続時間または離散時間LTIモデル SYS の伝達関数を
% 状態空間モデルに対して、結果は、つぎのようになります。 
%                                    -1
%        FRESP =  D + C * (X * E - A)  * B  
%
% EVALFR は、FREQRESP の簡易版で、単一点での応答を迅速に求めることができます。
% 複数の周波数に対する周波数応答を求めるには、FREQRESP を利用します。
%
% 参考 : FREQRESP, BODE, SIGMA, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
