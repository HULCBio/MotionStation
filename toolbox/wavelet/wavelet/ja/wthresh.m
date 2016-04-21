% WTHRESH       ソフトスレッシュホールドまたはハードスレッシュホールド処理
% Y = WTHRESH(X,SORH,T) は、入力ベクトルまたは行列 X へソフト (SORH = 's')、また
% は、ハード(SORH = 'h')スレッシュホールドを使ってスレッシュホールド値 T を適用
% した結果 Y を出力します。
%
% Y = WTHRESH(X,'s',T) は、Y = SIGN(X).(|X|-T)+ を出力します。ソフトスレッシュホ
% ールド処理は、ウェーブレットをある範囲で減少させます。
%
% Y = WTHRESH(X,'h',T) は、Y = X.1_(|X|>T) を出力します。ハードスレッシュホール
% ド処理は、よりはっきりとしています。
%
% 参考： WDEN, WDENCMP, WPDENCMP.



%   Copyright 1995-2002 The MathWorks, Inc.
