% WAVEFUN2   2次元のウェーブレット関数とスケーリング関数
%
% WAVEFUN2 は、ウェーブレット関数 'wname' と関連したスケーリング関数の
% 近似が存在する場合に出力します。
%
% [S,W1,W2,W3,XYVAL] = WAVEFUN2('wname',ITER) は、直交ウェーブレットに
% 対して1次元のスケーリング関数とウェーブレット関数のテンソル積からス
% ケーリング関数と3つのウェーブレット関数の結果を出力します。
%
% より正確には、[PHI,PSI,XVAL] = WAVEFUN('wname',ITER) の場合、スケー
% リング関数 S は、PHI と PHI のテンソル積です。ウェーブレット関数 W1,
% W2 および W3 は、それぞれ (PSI,PHI) および (PSI,PSI) と (PHI,PSI) と
% のテンソル積です。2次元変数 XYVAL は、テンソル積 (XVAL,XVAL) から得
% られる (2^ITER) x (2^ITER) 点のグリッドです。正の整数 ITER は、繰り
% 返し数です。
%
% ... = WAVEFUN2(...,'plot') は、計算と、付加的に関数をプロットします。
%
% WAVEFUN2('wname',A,B) は (ここで、A,B は正の整数)、WAVEFUN2('wname',
% max(A,B)) と等価で、プロット表示も行われます。
%
% WAVEFUN2('wname',0) は、WAVEFUN2('wname',4,0) と等価です。
% WAVEFUN2('wname') は、WAVEFUN2('wname',4) と等価です。
%
% 参考 : INTWAVE, WAVEFUN, WAVEINFO, WFILTERS.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
