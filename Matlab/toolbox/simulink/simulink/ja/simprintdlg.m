% SIMPRINTDLG   プリントダイアログボックス
%
% SIMPRINTDLG(sys) は、システム sys をプリントするダイアログボックスを作成し
% ます。SIMPRINTDLG は、カレントのシステムをプリントします。
% sys は、ハンドルまたは文字列の名前です。
%
% SIMPRINTDLG('-crossplatform',sys) は、PC、および、Macintoshの組み込みプリン
% トダイアログではなく、標準のクロスプラットフォームMATLABプリントダイアログ
% を表示します。このオプションは、それ以外のオプションの前に挿入されます。
%
%
% つぎのオプションは、コマンドラインで利用することを意図しています。
% プリントダイアログは開きません。
%
% [Systems,PrintLog] = .... SIMPRINTDLG(Sys,SysOpt,LookUnderMask,
% Systems     - プリントする System のハンドルのリストとプリントの順番。 S
%               tateflowのハンドルも含みます。
% Stateflowのハンドルは、プリントすると、削除する必要があります。
% PrintLog    - プリントログのテキストバージョン。
%
% Sys は、プリントダイアログが起動されたシステムです。
%
% SysOpt は、'CurrentSystem'        , 'CurrentSystemAndAbove','
% CurrentSystemAndBelow', 'AllSystems'です。
%
% LookUnderMask は、マスクの下層を表示しない場合は0で、すべてのシステムを表示
% する場合は1です。
%
% ExpandLibLinks は、最初のライブラリリンクで停止する場合は0で、リンクの下層
% を表示する場合は1です。
%
%
% SIMPRINTDLG(Sys,SysOpt,LookUnderMask,ExpandLibLinks,PrintInfo)で、
% PrintInfo は、つぎのフィールド、PrintLog, PrintFrame, FileName,
% PrintOptions, PaperType, PaperOrientationをもつデータ構造体です。
% PrintLog, PrintFrame, FileName, PrintOptions, PaperType,
% PaperOrientation.
%
% PrintLog が'on'である場合は、ログファイルもプリントされます。
% PrintLogが 'off'または '' である場合は、ログファイルはプリントされません。
%
% PrintFrame が、'' である場合は、プリントジョブにプリントフレームは含まれません
% 。そうでない場合、PrintFrame が空でなく、有効なprintframeファイルである場合
% は、printframesは出力に含まれます。
%
% FileName が空の場合も、出力がプリントされます。
% FileName が空でない場合は、出力は FileName という名前で、適切な拡張子(例
% txt, ps, eps)をもつファイルに保存されます。txt, ps, eps).
%
% PaperType と PaperOrientation は、これらのプロパティに対する有効な設定のい
% ずれかで構いません。
%
% PrintOptions は、printコマンドに指定したプリントオプションを付加します。
%
% つぎの PrintData 構造体の例は、encapsulated postscript を用いて、プリントロ
% グを含まず、printframeをもつファイルを出力します。 PrintData.PrintLog='
% off'; PrintData.PrintFrame='sldefaultframe.fig'; PrintData.FileName='
% myprintoutput'; PrintData.PrintOptions='-deps'; PrintData.
% PaperOrientation='landscape'; PrintData.PaperType='usletter';
%
% 参考 : SIMPRINTLOG, FRAMEEDIT, PRINT.


% Copyright 1990-2002 The MathWorks, Inc.
