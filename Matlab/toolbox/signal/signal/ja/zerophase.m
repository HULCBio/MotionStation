% ZEROPHASE 実際のフィルタの零点-位相応答を出力します。
% [Hr,W] = ZEROPHASE(B,A)は、零点-位相応答Hrと、Hrが計算される
% 周波数ベクトルW を(rad/sampleで)出力します。
% 零点-位相応答は、単位円の上半周に等間隔に並ぶ 512点で評価されます。 
%
% 零点-位相応答Hr(w)は、周波数応答H(w)とつぎの関係があります。
%                                       jPhiz(w)
%                          H(w) = Hr(w)e
%
% 零点-位相応答は、常に実数ですが、絶対値での応答とは等価ではない
% ことに注意してください。特に、前者は、負になることができますが、
% 後者は、負になることはありません。
%
% [Hr,W] = ZEROPHASE(B,A, NFFT)は、零点-位相応答を計算する場合、単位円の
% 上半円周のNFFT周波数点を使用します。
%
% [Hr,W] = ZEROPHASE(B,A,NFFT,'whole') は、単位円の全周のNFFT周波数の点
% を使用します。
%
% [Hr,W] = ZEROPHASE(B,A,W) は、ベクトルWで示される
% radians/sample (通常、0 とπの間)の、周波数での零点‐位相応答
% を出力します。
%
% [Hr,F] = ZEROPHASE(...,Fs) は、Hzで表されるサンプリング周波数を使用して、
% Hr が計算される、周波数ベクトルF (Hzで表す)を決定します。
%
% [Hr,W,Phi] = ZEROPHASE(...) は、連続位相Phiを出力します。
% この量は、零点‐位相応答が負である場合、フィルタの位相応答に等価では
% ありません。
%
% ZEROPHASE(...)が、出力引数を持たない場合、零点- 位相応答を周波数に対して
% プロットします。 
%
% 例題 #1:
%     b=fircls1(54,.3,.02,.008);
%     zerophase(b)
%
% 例題 #2:
%     [b,a] = ellip(10,.5,20,.4);
%     zerophase(b,a,512,'whole')
%
% 参考 FREQZ, INVFREQZ, PHASEZ, FREQS, PHASEDELAY, GRPDELAY, FVTOOL.

%   Copyright 1988-2002 The MathWorks, Inc.
