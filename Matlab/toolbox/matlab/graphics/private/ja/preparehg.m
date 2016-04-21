% PREPAREHG   印刷のためのFigureの準備
% プロパティ値とPrintJobの状態に基づいて、Figureとその子オブジェクトのプロパティ
% を修正します。変更は、オブジェクトのカラーとResizeFcnが呼び出される必要が場合
% は、スクリーン上のFigureのサイズを含みます。
% Figureとその子のリストアのために保存しなければならない種々のデータを含むフィー
% ルドをもつ構造体を作成し、出力します。
%
% 例題:
% 
%    pj = PREPAREHG( pj、h ); % PrintJobオブジェクトpjとFigure hを修正
%
% 参考：PRINT, PREPARE, RESTORE, RESTOREHG.

%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:41 $
%   Copyright 1984-2002 The MathWorks, Inc. 
