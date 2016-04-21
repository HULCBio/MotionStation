%GET WVTREE オブジェクトフィールドの内容を取得
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) は、WVTREE オブジェクト T
%   に対する、指定されたフィールドの内容を取得します。
%   オブジェクト、または構造体のフィールドに対して、サブフィールドの内容%   を取得できます (DTREE/GET を参照)。
%
%   [...] = GET(T) は、T のすべてのフィールドの内容を出力します。
%
%   'FieldName' で選択できる内容は以下の通りです。
%     'dummy'   : 使用しません。
%     'wtree'   : wtree の親オブジェクトです。
%
%   または、WTREE の親オブジェクト内のフィールドは以下の通りです。
%     'dwtMode' : DWT 拡張モード
%     'wavInfo' : 構造体 (ウェーブレットの情報)
%        'wavName' - ウェーブレット名
%        'Lo_D'    - 分解側ローパスフィルタ
%        'Hi_D'    - 分解側ハイパスフィルタ
%        'Lo_R'    - 再構成側ローパスフィルタ
%        'Hi_R'    - 再構成側ハイパスフィルタ
%
%   'FieldName' のその他の有効な選択についてのより詳細な情報に関しては、%    help dtree/get とタイプしてください。
%
%   参考 : DTREE/READ, DTREE/SET, DTREE/WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.



%   Copyright 1995-2002 The MathWorks, Inc.
