% WAVEFUN　 1次元のウェーブレット関数とスケーリング関数
%
% WAVEFUN は、ウェーブレット関数 'wname' と関連したスケーリング関数の近
% 似が存在する場合に出力します。正の整数 ITER は、計算の繰り返し回数を設
% 定します。
%
% 直交ウェーブレットの場合
% [PHI,PSI,XVAL] = WAVEFUN('wname',ITER) は、2^ITER 点のグリッド XVAL 上
% で、スケーリング関数とウェーブレット関数を出力します。
%
% 双直交ウェーブレットの場合
% [PHI1,PSI1,PHI2,PSI2,XVAL] = WAVEFUN('wname',ITER) は、分解(PHI1,PSI1)
% 及び再構成(PHI2、PSI2)の双方に対して、スケーリング関数とウェーブレット
% 関数を出力します。
%
% Meyer ウェーブレットの場合
%   [PHI,PSI,XVAL] = WAVEFUN('wname',ITER)
%
% スケーリング関数をもたないウェーブレットの場合(たとえば、Morlet,Mexic-
% an Hat または Gaussian 微分ウェーブレットの場合)
%   [PSI,XVAL] = WAVEFUN('wname',ITER) 
%
% ... = WAVEFUN(...,'plot') は、計算と、付加的に関数をプロットします。
%
% WAVEFUN('wname',A,B) は (ここで、A,B は正の整数)、WAVEFUN('wname',max 
%   (A,B)) 
% と等価で、プロット表示も行われます。
% WAVEFUN('wname',0) は、WAVEFUN('wname',8,0) と等価です。
% WAVEFUN('wname') は、WAVEFUN('wname',8) と等価です。
% 
% 参考： INTWAVE, WAVEINFO, WFILTERS.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
