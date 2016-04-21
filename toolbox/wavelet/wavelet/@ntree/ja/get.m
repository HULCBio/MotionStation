%GET   NTREE オブジェクトフィールドの内容を取得
%
% [FieldValue1,FieldValue2, ...] = ...
%     GET(T,'FieldName1','FieldName2', ...) は、NTREE オブジェクト T で
% 指定されるフィールドの内容を出力します。
%
% [...] = GET(T) は、Tのすべてのフィールドの内容を出力します。
%
% 'FieldName' で使用できる値は、以下のとおりです。
%   'wtbo'  : 親オブジェクト
%   'order' : ツリーの次数
%   'depth' : ツリーの深さ
%   'spsch' : ノードの分離手法
%   'tn'    : 末端ノードインデックスをもつ配列
%
% または、WTBO 親オブジェクトのフィールドは以下のとおりです。
%   'wtboInfo' : オブジェクト情報
%   'ud'       : ユーザデータフィールド
%
%   例題:
%     t = ntree(3,2);
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%
%   参考: DISP, SET


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
