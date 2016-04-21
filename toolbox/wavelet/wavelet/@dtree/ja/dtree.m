%DTREE   DTREE クラス用のコンストラクタ
%   T = DTREE(ORD,D,X) は、次数 ORD と、深さ D の完全なデータツリーオブ
%   ジェクトを出力します。データは、ツリー T と X に関連づけられていま
%   す。
%
%   T = DTREE(ORD,D,X,USERDATA) を使って、ユーザデータフィールドを設定で%   きます。
%
%   [T,NB] = DTREE(...) は、T の末端ノード(レベル)の数も出力します。
%
%   T = DTREE('PropName1',PropValue1,'PropName2',PropValue2,...) は、
%   DTREE オブジェクトで構築される最も一般的なシンタックスです。
%   'PropName' に対する有効な選択は以下の通りです。
%     'order' : ツリーの次数
%     'depth' : ツリーの深さ
%     'data'  : ツリーに関連するデータ
%     'spsch' : ノードの分解手法
%     'ud'    : ユーザデータフィールド
%
%   Split scheme フィールドは論理配列1による ORD です。
%   ツリーのルートは split で、 ORD の子ノードをもちます。
%   SPSCH(j) = 1 の場合、j番目の子ノードは、split になります。
%   各ノードにおいて、split はルートのノードと同じプロパティをもちます。%
%   関数 DTREE は、DTREE オブジェクトを出力します。
%   オブジェクトフィールドについてのより詳細な情報については、
%   help dtree/get をタイプしてください。
%
%   参考: NTREE, WTBO

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.



%   Copyright 1995-2002 The MathWorks, Inc.
