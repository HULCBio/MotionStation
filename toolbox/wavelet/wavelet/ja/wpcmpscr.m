% WPCMPSCR　 1次元または2次元ウェーブレットパケット圧縮スコア
% [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,DATA) は、入力ウェーブレットパケット分
% 解構造 [TREE,DATA] に対して、Approximation 係数を保持した状態で、圧縮スコア及
% び推奨スレッシュホールド値を出力します。
% THR は、ベクトルまたは指定されたスレッシュホールド値であり、THR(i)-threshold-
% ing によって導かれたスコアに対応するベクトルです。
% RL2 は、2ノルムの回復スコア(%表示)です。
% NZ は、0の相対数のベクトル(%表示)です。
% IMIN は、2つのスコアが近似的に同値である THR のインデックスです。
% STHR は推奨スレッシュホールド値です。
%
% 3つの入力引数が用いられた場合、WPCMPSCR(TREE,DATA,IN3) は、同一の出力値を返し
% ますが、すべての係数にスレッシュホールド処理が施されます。
%
% 参考： KEY2INFO, WCMPSCR.



%   Copyright 1995-2002 The MathWorks, Inc.
