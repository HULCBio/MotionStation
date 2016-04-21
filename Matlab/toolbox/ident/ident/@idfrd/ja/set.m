% SET は、IDFRD モデルのプロパティを設定します。
%
% SET(SYS,'PropertyName',VALUE) は、IDFRD モデル SYS のプロパティ
% 'Property Name' を値 VALUE に設定します。等価な表現は、つぎのものです。
% 
%       SYS.PropertyName = VALUE .
%
% SET(SYS,'Property1',Value1,'Property2',Value2,...) は、複数の IDFRD プ
% ロパティ値を単一のステートメントで設定します。
%
% SET(SYS,'Property') は、SYS の指定したプロパティに関する設定可能な値を
% 表示します。
%
% SET(SYS) は、SYS のすべてのプロパティと関連した値を表示します。IDFRD プ
% ロパティの詳細は、IDPROPS IDFRD と入力してください。
%
% 注意：
% サンプリング時間を設定し直しても、モデルデータに変更はありません。連続
% 領域と離散領域の間の変換は、C2D と D2C を使ってください。
%
% 参考： GET, IDPROPS IDFRD



%   Copyright 1986-2001 The MathWorks, Inc.
