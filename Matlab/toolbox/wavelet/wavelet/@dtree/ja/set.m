%SET   DTREE オブジェクトフィールドの内容を設定
%   T = SET(T,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...) 
%   は、DTREE オブジェクト T で指定されたフィールドの内容を設定します。
%   
%   'FieldName' で選択できる内容は以下の通りです。
%     'ntree' : 親オブジェクト
%     'allNI' : すべてのノードの情報
%     'terNI' : 末端ノードの情報
%
%   または、NTREE 親オブジェクトのフィールド
%     'wtbo'  : 親オブジェクト
%     'order' : ツリーの次数
%     'depth' : ツリーの深さ
%     'spsch' : ノードの分離手法
%     'tn'    : 末端ノードインデックスをもつ配列
%
%   または、WTBO 親オブジェクトのフィールド
%     'wtboInfo' : オブジェクト情報
%     'ud'       : ユーザデータフィールド
%
%   注意: フィールド 'ud' は、SET 関数しか使用できません。
%
%   参考: DISP, GET, READ, WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
