% WPTHCOEF    ウェーブレットパケット係数にスレッシュホールド処理を適用
% NDATA = WPTHCOEF(DATA,TREE,KEEPAPP,SORH,THR)は、係数のスレッシュホールドを使っ
% てウェーブレットパケット分解構造 [DATA,TREE] (MAKETREE 参照)から得られる新しい
% データ構造を出力します。
%
% KEEPAPP = 1 の場合、 Approximation 係数にはスレッシュホールド処理が適用されず、
% 他の場合には適用されます。SORH = 's' の場合、ソフトスレッシュホールド処理が適
% 用され、SORH = 'h' の場合、ハードスレッシュホールド処理が適用されます(詳細は、
% WTHRESH 参照)。THR は、スレッシュホールド値です。
%
% 参考： MAKETREE, WPDEC, WPDEC2, WPDENCMP, WTHRESH.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
