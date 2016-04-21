% TREEPRUNE   枝を取り除くことによるサブツリーの列の生成
%
% T2 = TREEPRUNE(T1,'level',LEVEL) は、TREEFIT 関数によって作成された
% 決定木 T1 と削除(pruning)レベル LEVEL を取って、そのレベルで枝が取り
% 除かれた決定木 T2 を出力します。LEVEL=0 の値は、何も取り除かれないこ
% とを意味します。ツリーは、最初に取り除く枝が、エラーのコストの増加を
% 最小に抑えるように、最適な削除(pruning)計画をもとに取り除かれます。
%
% T2 = TREEPRUNE(T1,'nodes',NODES) は、ツリーからの NODES ベクトル内に
% リストされたノードを取り除きます。これらの親も取り除かれていない場合、
% NODES にリストされたどんな T1 枝のノードも、T2 内の葉のノードになり
% ます。TREEDISP 関数は、選択した任意のノードに対してノード番号を表示
% することができます。
%
% T2 = TREEPRUNE(T1) は、T1 から何も取り除いていない完全な決定木に最適
% な削除(pruning)情報を加えた決定木 T2 を出力します。これは、T1 が他の
% ツリーから削除を行って得られたものである場合、または、削除(pruning)
% の設定を 'off' にして TREEFIT 関数を使って作成された場合のみ有用です。
% 最適な削除を行う(pruning)手順に沿って、ツリーを複数回取り除く場合、
% 最初に最適な削除を行う(pruning)列を作成することはより効果があります。
%
% 枝を取り除くことは、いくつかの枝ノードを葉のノードに変えて、オリジナル
% の枝の下の葉のノードを削除することにより、ツリーを縮小する処理です。
%
% 例題:  最適な削除(pruning)手順に沿って、Fisherの ires data に対する
% 完全なツリーと2番目に大きなツリーを表示します。
%    load fisheriris;
%    t = treefit(meas,species,'splitmin',5);
%    treedisp(t);
%    t1 = treeprune(t,'level',1);
%    treedisp(t1);
%
% 参考 : TREEFIT, TREETEST, TREEDISP, TREEVAL.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/03/26 14:57:28 $

