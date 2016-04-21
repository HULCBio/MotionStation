% PARETO   Paretoチャート
% 
% PARETO(Y,NAMES) は、ベクトル Y の値を棒状で降順に描画するParetoチャート
% を作成します。各バーは、文字列行列またはセル配列 NAMES の関連する名前で
% ラベル付けられます。
%
% PARETO(Y,X) は、Y の各要素を、X の値を使ってラベル付けします。PARETO(Y)
% は、Y の各要素を、要素のインデックスを使ってラベル付けします。
%
% PARETO(AX,...) は、GCAの代わりにメインのaxesとしてAXにプロットします。
%
% [H,AX] = PARETO(...) は、lineオブジェクトのハンドル番号を H に出力し、
% 作成された2つのaxesのハンドル番号を AX に出力します。
%
% 参考：HIST, BAR.


%   Copyright 1984-2002 The MathWorks, Inc. 
