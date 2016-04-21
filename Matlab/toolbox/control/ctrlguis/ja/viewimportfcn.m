% VIEWIMPORTFCN   すべての CODA Import ウィンドウのために含まれる標準の関数
%
% DATA = VIEWIMPORTFCN(ACTION,ImportFig) は、ImportFig のハンドルをもつ
% Import figure上で、文字列 ACTION によって指定されたアクションを実行
% します。出力は、どのアクションが入力されたかに依存し、DATA 内に返されます。

% 可能な ACTION:
%   1) broswemat:     MAT-ファイルの位置に対する標準のMATLABブラウザを開く
%   2) radiocallback: ラジオボタンに対するアクションを実行
%   3) matfile:       MAT-ファイルのラジオボタンに対するアクションを実行
%   4) workspace:     ワークスペースのラジオボタンに対するアクションを実行


%   Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/06/26 16:07:19 $
