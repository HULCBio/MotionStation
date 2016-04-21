% SET   LTIモデルのプロパティを設定
%
%
% SET(SYS,'PropertyName',VALUE) は、値 VALUE をLTIモデル SYS のプロパティ'
% PropertyName' に設定します。同様の設定ができる書式は、SYS.PropertyName =
% VALUE です。
%
% SET(SYS,'Property1',Value1,'Property2',Value2,...) は、複数のLTIプロパティ
% 値を1つのステートメントで設定します。
%
% SET(SYS,'Property') は、SYS のプロパティを設定するために設定可能な値を表示
% します。
%
% SET(SYS) は、SYS のすべてのプロパティと設定可能な値を表示します。
% LTIプロパティの詳細を参照するためには、HELP LTIPROPS とタイプしてください。
%
% 注意: サンプル時間を変更してもモデルデータは変更されません。
%  連続領域と離散領域の変換には、C2D または D2D を利用してください。
%
% 参考 : GET, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
