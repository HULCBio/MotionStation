% TREEVAL   データに適用した決定木に対する近似値の計算
%
% YFIT = TREEVAL(TREE,X) は、TREEFIT 関数で生成した分類、または回帰木
% TREE と予測子の行列 X を取り込み、予測された応答値のベクトル YFIT を
% 生成します。回帰木については、YFIT(j) は、予測子 X(j,:) をもつ点に
% 対する近似された応答値です。分類木については、YFIT(j) は、データ 
% X(j,:) に対応する点にツリーが割り当てる分類番号です。番号からクラス
% 名に変換するために、3番目の出力引数(以下を参照)を使います。
%
% YFIT = TREEVAL(TREE,X,SUBTREES) は、他に、0が完全な、何も取り除か
% ないツリーを示すような、削除(pruning)レベルのベクトル SUBTREES を
% 取り込みます。TREE は、TREEFIT または TREEPRUNE 関数で作成された削除
% (pruning)列を含んでいなければなりません。SUBTREES が K 個の要素で、
% X が N 行の場合、出力 YFIT は、J番目の列が SUBTREES(J) のサブツリー
% によって生成された近似値を含む N×K 行列です。SUBTREES は、昇順の
% 並びでなければなりません。(最適な削除(pruning)列の一部ではないツリー
% に対する近似値を計算するには、ツリーの枝を取り除くために、最初に 
% TREEPRUNE を使用してください)
%
% [YFIT,NODE] = TREEVAL(...) は、X の各行に割り当てられたノード番号を
% 含んだ YFIT と同じ大きさの配列 NODE を出力します。TREEDISP 関数は、
% 選択した任意のノードに対してノード番号を表示することができます。
%
% [YFIT,NODE,CNAME] = TREEVAL(...) は、分類木に対してのみ有効です。
% 予測された分類名を含むセル配列 CNAME を出力します。
%
% X 行列内の NaN 値は、欠損値として扱われます。枝ノードで分離規則を
% 実行しようとするときに、TREEVAL 関数が欠損値に遭遇した場合、左右の
% どちらかの子ノードに移るべきかどうか決定できません。その代わりに、
% 枝ノードに割り当てられた近似値を対応する近似値と設定します。
%
% 例題: Fisher の iris data に対して予測分類を行います。
%    load fisheriris;
%    t = treefit(meas, species);  % 決定木の作成
%    sfit = treeval(t,meas);      % 割り当てられた分類番号を検索
%    sfit = t.classname(sfit);    % 分類名
%    mean(strcmp(sfit,species))   % 正確に分類された比率を計算
%
% 参考 : TREEFIT, TREEPRUNE, TREEDISP, TREETEST.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/03/21 20:36:31 $

