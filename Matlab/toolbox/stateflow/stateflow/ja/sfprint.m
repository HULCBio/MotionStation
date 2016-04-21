%SFPRINT Stateflowダイアグラムの印刷
%   SFPRINTは、カレントのStateflowダイアグラムの表示されている範囲を印刷し
%   ます。
%
%   SFPRINT(objects, format, outputOption, printEntireChart)は、転送
%   されたオブジェクトのいずれかのチャートをファイルまたはデフォルトプリンタ
%   に印刷します。
%
%   オブジェクトパラメータは、Stateflowチャート、Simulinkモデル、システム
%   またはブロック、またはこれらを組み合わせたもの(セル配列またはハンドルの
%   ベクトル)の名前あるいはid(ハンドル)になります。
%
%   formatsの一覧:
%        'default'
%        'ps'         ポストスクリプトファイルの生成
%        'psc'        カラーポストスクリプトファイルの生成
%        'eps'        EPS(encapsulated postscript)ファイルの生成
%        'epsc'       カラーEPS(encapsulated postscript)ファイルの生成
%        'tif'        TIFFファイルの生成
%        'jpg'        JPEGファイルの生成
%        'png'        PNGファイルの生成
%        'meta'       Stateflowイメージをメタファイルとしてクリップボード
%			  に保存(PCのみで可!)
%        'bitmap'     Stateflowイメージをビットマップファイルとしてクリップ
%			  ボードに保存(PCのみで可!)
%
%        フォーマットパラメータが存在しない場合(sfprintが1つの引数でコール
%        された場合)は、フォーマットはデフォルトの'ps'か使われ、出力はデフォ
%        ルトプリンタに送られます。
%
%   可能なoutputOptions:
%        ファイル名の文字列		  書き込むファイルを指定します(印刷する
%					  ものが複数ある場合、ファイルは上書き
%					  されます)
%        'promptForFile' キーワード ダイアログを使って尋ねられるファイル名
%        'printer' キーワード       出力は、デフォルトのプリンタに送られます
%                                   ('default', 'ps' ,'eps' フォーマット
%					  のいずれかが使用可)
%        'file'          キーワード  出力は、デフォルトのファイルに送られます
%                                   <オブジェクトのパス>.<デバイスの拡張子>
%        'clipboard',    キーワード　出力は、クリップボードにコピーされます
%
%        outputOptionパラメータが存在しないか、あるいは空の場合は、カレント
%	  ディレクトリのデフォルトファイル名(チャート名)が使われます。
%
%   printEntireChartパラメータはオプションです。2つの使用可能な値があります。
%        1 (デフォルト)   全体のチャートを印刷
%        0             チャートの中でカレントに可視化されているものを印刷
%
%   例題:
%      sfprint(id, 'tif', ...
%                  'myFilename'); % チャート/サブチャート(id)をtiffファイ
%					 % ルに印刷
%
%      sfprint( gcs )              % カレントシステムのすべてのチャートを印刷
%
%      sfprint( gcb, 'jpg', ...    % カレントブロック(Stateflowブロックの場合
%             'promptForFile')     % をJPEGフォーマットで(ダイアログで指定
%					  % した名前でファイルに印刷
%
%      sfprint( gcs, 'tif', ...    % デフォルトファイル名を使って、
%             'file', 1);          % カレントシステム 内のすべてのStateflow
%					  % チャートを印刷。全体のチャートを印刷。
%
%   参考　STATEFLOW, SFNEW, SFSAVE, SFEXIT, SFHELP.

%   Copyright (c) 1995-2002 The MathWorks, Inc.
