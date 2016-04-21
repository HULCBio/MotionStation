%GET   WPTREE オブジェクトフィールドの内容を取得
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) は、WPTREE オブジェクト T %   で指定されるフィールドの内容を出力します。
%   オブジェクト、または構造体のフィールドに対して、サブフィールドの内容%   を取得することができます (以下の例題をご参照ください)。
%
%   [...] = GET(T) は、Tのすべてのフィールドの内容を出力します。
%
%   'FieldName' で使用できる値は、以下のとおりです。
%     'dtree'   : DTREE 親オブジェクト
%     'wavInfo' : 構造体 (ウェーブレット情報)
%        'wavName' - ウェーブレット名
%        'Lo_D'    - 分解ローパスフィルタ
%        'Hi_D'    - 分解ハイパスフィルタ
%        'Lo_R'    - 再構成ローパスフィルタ
%        'Hi_R'    - 再構成ハイパスフィルタ
%
%     'entInfo' : 構造体 (エントロピー情報)
%        'entName' - エントロピー名
%        'entPar'  - エントロピーパラメータ
%
%   または、DTREE 親オブジェクトのフィールド
%     'ntree' : NTREE 親オブジェクト
%     'allNI' : すべてのノード情報
%     'terNI' : 末端ノード情報
%     ------------------------------------------------------------------%      FieldName = 'allNI' に対して、FieldValue の allNI は、以下のよう
%      な NBnodes行5列の配列になります。
%      allNI(N,:) = [ind,size(1,1),size(1,2),ent,ento]
%          ind  = ノード N のインデックス
%          size = ノード N で関連づけられたデータのサイズ
%          ent  = ノード N のエントロピー
%          ento = 最適なエントロピーノード N
%     ------------------------------------------------------------------%      FieldName = 'terNI' に対して、FieldValue の terNI は、以下のよう
%      な1行2列のセル配列になります。
%      terNI{1} は、以下のような NB_TerminalNodes行2列の配列になります。%         terNI{1}(N,:) は、N番目の末端ノードに関連づけられた係数のサイ
%         ズです。ノードは、左から右に、上から下に番号づけられています。%         ルートインデックスは0です。
%      terNI{2} は、上記で設定した順に行方向にストアされた前の係数を含む%      行ベクトルです。
%     ------------------------------------------------------------------%
%   もしくは、NTREE 親オブジェクト内のフィールド
%     'wtbo'  : wtbo 親オブジェクト
%     'order' : ツリーの次数
%     'depth' : ツリーの深さ
%     'spsch' : ノードの分離手法
%     'tn'    : ツリーの末端ノードの配列
%
%   もしくは、WTBO 親オブジェクト
%     'wtboInfo' : オブジェクト情報
%     'ud'       : ユーザデータフィールド
%
%   例題:
%     x = rand(1,1000);
%     t = wpdec(x,2,'db2');
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%     [o,allNI,tn] = get(t,'order','allNI','tn');
%     [o,wavInfo,allNI,tn] = get(t,'order','wavInfo','allNI','tn');
%     [o,tn,Lo_D,EntName] = get(t,'order','tn','Lo_D','EntName');
%     [wo,nt,dt] = get(t,'wtbo','ntree','dtree');
%
%   参考: DISP, READ, SET, WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
