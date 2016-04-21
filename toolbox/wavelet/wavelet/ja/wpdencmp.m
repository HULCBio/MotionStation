% WPDENCMP 　ウェーブレットパケットを用いた雑音除去または圧縮
% [XD,TREED,DATAD,PERF0,PERFL2] = WPDENCMP(X,SORH,N,'wname',CRIT,PAR,KEEPAPP) は、
% ウェーブレットパケット係数のスレッシュホールド手法により得られる入力信号 X (1
% 次元または2次元)の雑音除去したものかまたは圧縮したものを出力します。
% 付加的な出力引数 [TREED,DATAD] は、XD のウェーブレットパケットの最適分解構造で
% す。一方、PERFL2 及び PERF0 は、L^2 回復と圧縮スコアを%表示で示したものです。
% PERFL2 = 100*(XD の WP-cfs のベクトルノルム)^2 /(X の WP-cfs のベクトルノルム)
% ^2
% SORH ('s' または 'h') は、ソフトスレッシュホールドまたはハードスレッシュホール
% ド(詳細は WTHRESH を参照)のいずれかです。
% 
% ウェーブレットパケット分解は、レベル N で行われ、'wname' は、ウェーブレット名
% を示す文字列です。最適分解は、文字列 CRIT とパラメータ PAR(詳細は、WENTROPY 参
% 照)により設定されるエントロピー規範を使って実現されます。スレッシュホールドパ
% ラメータは PAR です。KEEPAPP = 1 の場合、Approximation 係数にはスレッシュホー
% ルドが適用できず、他の場合、スレッシュホールドが適用可能となります。
%
% [XD,TREED,DATAD,PERF0,PERFL2]  = WPDENCMP(TREE,DATA,SORH,CRIT,PAR,KEEPAPP) は、
% 上述のものと同じオプションを使って同じ出力引数を出力しますが、雑音除去または圧
% 縮される信号の入力ウェーブレットパケット分解構造 [TREE,DATA] から出力が直接得
% られます。加えて、CRIT = 'nobest' の場合、最適化は適用されず、カレントの分解に
% スレッシュホールドが適用されます。
%
% 参考： DDENCMP, WDENCMP, WENTROPY, WPDEC, WPDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.
