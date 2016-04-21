% ICCEPS 逆複素セプストラム
% ICCEPS(xhat,nd) は、遅延分 nd サンプルを除去した(実数と仮定している)デ
% ータ列 xhat の逆複素セプストラムを出力します。xhat が、CCEPS(x)から求
% められている場合、xに付加した遅延総量は、πラジアンに対応する round
% (unwrap(angle(fft(x)))/pi) の要素になります。
%
% 参考：   CCEPS, RCEPS, HILBERT, FFT.



%   Copyright 1988-2002 The MathWorks, Inc.
