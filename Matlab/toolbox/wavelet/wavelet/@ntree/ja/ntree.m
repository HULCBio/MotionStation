%NTREE   クラス NTREE 用のコンストラクタ
%   T = NTREE(ORD,D) は、次数 ORD と深さ D のすべてのツリーである NTREE %   オブジェクトを出力します。
%
%   T = NTREE は、T = NTREE(2,0) と等価です。
%   T = NTREE(ORD) は、T = NTREE(ORD,0) と等価です。
%
%   T = NTREE(ORD,D,S) を使うことで、ノードに対する "分離手法" を設
%   定することができます。
%   分離手法 S は、論理配列1による ORD です。
%   ツリーのルートが分解されると、ORD の子ノードになります。
%   S(j) = 1 のとき、j番目の子ノードは分解されています。
%   各ノードは、分解によりルートノードと同じプロパティをもちます。
%
%   T = NTREE(ORD,D,S,U) を使って、ユーザデータフィールドを設定します。
%
%   他の使用法として、
%   T = NTREE('order',ORD,'depth',D,'spsch',S,'ud',U)
%   "missing" 入力に対するデフォルトは、以下のとおりです。
%        ORD = 2, D = 0, S = ones([1:ORD]), U = [] 
%
%   [T,NB] = NTREE(...) は、T の末端ノード(レベル) の番号も出力します。
%
%   関数 NTREE は、NTREE オブジェクトを出力します。
%   オブジェクトフィールドのより詳細な情報に関しては、help ntree/get を
%   タイプしてください。
%
%   参考: WTBO

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.



%   Copyright 1995-2002 The MathWorks, Inc.
