% WCMPSCR 　1次元または2次元ウェーブレット圧縮スコア
% [THR,RL2,NZ,IMIN,STHR] = WCMPSCR(C,L) は、入力されたウェーブレット分解構造 [C,
% L] に対して、スレッシュホールドを適用する Detail 係数と指示されたスレッシュホ
% ールドに関する圧縮スコアを出力します。
%
% 出力は、以下のとおりです。 
% THR ベクトル、または、指示されたスレッシュホールド及び THR(i) スレッシュホール
% ドによってもたらされるスコアのベクトル
% 
% RL2 は、%表示された、2ノルムの回復スコアのベクトル 
% NZ  は、%表示された0の相対数のベクトル 
% IMIN は、2つのスコアが近似的に同値である THR のインデックス
%
% STHR は、スレッシュホールドを示します。
%
% 3つの引数を用いたとき、WCMPSCR(C,L,IN3) は、同一の結果を出力しますが、Approx-
% imation 係数および Detail 係数に対してはスレッシュホールドが適用されます。
%
% 参考： KEY2INFO, WPCMPSCR.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
