% TREEDISP   分類または回帰木のグラフィカルな表示
%
% TREEDISP(T) は、TREEFIT 関数によって計算された決定木 T を入力とし、
% figure ウィンドウに表示します。ツリーの各枝には、決定規則が表示され、
% 各終端ノードには、ノードに対する予測子が表示されます。任意のノードを
% クリックすることで、figure の一番上のポップアップメニューで指定されて
% いるようなノードに関する追加情報を得ることができます。
%
% TREEFIT(T,'PARAM1',val1,'PARAM2',val2,...) は、オプションパラメータ
% 名/値 の組み合わせを指定します。:
%
%    'names'       予測変数に対する名前のセル配列。
%                  ツリーが作成された X の行列内にそれらが現れる順です
%                  (TREEFIT を参照)
%    'prunelevel'  はじめに表示する枝の削除(pruning)レベル
%
% 各枝のノードに対して、左側の子ノードは条件を満たす点に対応し、右側の
% 子ノードは、条件を満たさない点に対応します。
%
% 例題:  Fisherの ires data に対する分類木を作成し、表示します。
%        名前は、列の内容(sepal length, sepal width, petal length, 
%        petal width)に対する略語です。
%    load fisheriris;
%    t = treefit(meas, species);
%    treedisp(t,'names',{'SL' 'SW' 'PL' 'PW'});
%
% 参考 : TREEFIT, TREETEST, TREEPRUNE, TREEVAL.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/05/09 18:27:30 $


