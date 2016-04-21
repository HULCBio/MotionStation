% IDPROPS   IDENT モデルとテータプロパティに関するヘルプ
%
% IDPROPS は、IDMODEL モデルの基本的なプロパティの詳細を与えます。
%
% IDPROPS(MODELTYPE) は、種々のタイプのモデルとデータで設定したプロパテ
% ィの詳細を与えます。文字列 MODELTYPE は、つぎのいずれかのモデルタイプ
% を選択できます。
%
%      'idpoly'    : 多項式モデル Ay=[B/F]u+[C/D]e (IDPOLY オブジェクト)
%      'idarx'     : 多変数 ARX モデル Ay=Bu+e (IDARX オブジェクト)
%      'idss'      : 状態空間モデル (IDSS オブジェクト)
%      'greybox'   : ユーザ定義の線形モデル (GREYBOX オブジェクト)
%      'idfrd'     : 同定される周波数応答データ (IDFRD オブジェクト)
%      'iddata'    : 基本データ記述 (IDDATA オブジェクト)
%      'algorithm' : アルゴリズムに関連したプロパティ
%      'estimation': 推定結果に関連したプロパティ
%   
%      idprops('idpoly')の省略型として、
%      idprops idpoly を使うこともできます。そして、先頭の3文字を使うこ
%       もできます。
%
% 参考： IDMODELS, SET, GET.

%   Copyright 1986-2001 The MathWorks, Inc.
