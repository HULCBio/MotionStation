% SF_RTW   Stateflow versions 1.1以上のバージョンについてRTWのビルドに必
%          要なStateflow情報を抽出
%
% SF_RTWは、TLC内部から呼び出され、RTWのビルドに必要なStateflowの情報を
% 抽出します。特に、RTWはStateflowが入力データ、出力データ、入力イベント、
% 出力イベント、チャートのワークスペースデータ、マシンのワークスペースデ
% ータのために用いる一意的な名前を知る必要があります。その基本的な動機は、
% RTWはこれらのデータを別の名前で作成するため、Stateflowに対するハッシュ
% 定義のリストを作成しなければならないからです。

%   Copyright 1994-2001 The MathWorks, Inc.
