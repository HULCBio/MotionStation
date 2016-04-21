% OPEN	 拡張子によるファイルのオープン
% 
% OPEN NAME 、NAME により設定されるオブジェクトのタイプに依存して種々の
% 事柄を行います。ここで、 NAME は文字列を含む必要があります。
%
% タイプ       実行
% ----         ------
% variable     Array Editor内に指定された配列をオープン
% .mat file    MATファイルをオープン。変数をワークスペース内の構造体に格納
% .fig file    Handle Graphics内にfigureをオープン
% .m   file    M-file Editor内にM-ファイルをオープン
% .mdl file    Simulinkでのモデルのオープン
% .html file   ヘルプブラウザにHTMLドキュメントをオープン
% .p   file    NAMEがPファイルを意味し、NAME が .p 拡張子で終了しない場合は、
%              マッチングするM-ファイルをオープン。NAMEが .p 拡張子で終了する
%	       場合は、エラーを表示。
%
% OPEN は、ファイルサーチに関して、LOAD と同様に機能します。
%
% NAME がMATLABパス上に存在する場合は、WHICH により出力されるファイルを
% オープンします。
%
% NAME がファイルシステム上に存在する場合は、NAME という名前のファイルを
% オープンします。
%
% 例題：
%
% open('handel')           handel という名前の変数をまず探します。そして
%                          つぎに、パス上で handle.mdl または、handle.m 
%                          を探します。これらのいずれも見つからない場合は、
%                          エラーが表示されます。
%
% open('handel.mat')       handle.mat がパス上に存在しない場合は、
%                          エラーを表示します。
%
% open('d:\temp\data.mat') data.mat が d:\temp に存在しない場合は、
%			   エラーを表示します。
%
% OPEN は、ユーザの拡張子を使うこともできます。拡張子 ".XXX" をもつファイ
% ルをオープンする場合は、OPEN は補助関数 OPENXXX を呼び出します。これは、
% 'OPEN' という名前の関数で、ファイル拡張子をもっているものです。
%
% たとえば、
%
% OPEN('foo.m') は、openm('foo.m') を呼び出します。
% OPEN foo.m は、openm('foo.m') を呼び出します。
% OPEN myfigure.fig は、openfig('myfigure.fig') を呼び出します。
%
% 新規のファイルタイプに対してハンドラを設定することにより、ユーザ独自
% の関数 OPENXXX を作成することができます。OPEN はパス上で見つかった 
% OPENXXX を呼び出します。 
%
% 参考：SAVEAS, WHICH, LOAD, UIOPEN, UILOAD, FILEFORMATS, PATH.


%   Chris Portal 1-23-98
%   Copyright 1984-2003 The MathWorks, Inc.
