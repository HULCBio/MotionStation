% SETOUTFILE   レポート出力ファイルの名前を変更
% SETOUTFILE(SETFILENAME,OUTFILENAME)は、SETFILENAMEで指定された設定ファ
% イルを、実行時にOUTFILENAMEで指定したファイル名の出力を生成するように
% 変更します。パスがOUTFILENAMEで指定される場合は、パスは指定したディレ
% クトリに設定され、そうでない場合は出力ディレクトリは現在の作業ディレク
% トリに設定されます。OUTFILENAME のファイル拡張子は無視されます。
%
% SETOUTFILE(SETFILENAME)は、SETFILENAMEと同じファイル名とディレクトリに
% 出力ファイルを自動的に書き出すように設定ファイルを変更します。
%
% SETOUTFILE(SETFILENAME,OUTFILENAME,INCREMENT)は、INCREMENTが'on'、また
% は、'off'のとき、"Increment report filename"オプションがon、または、
% offであるように設定ファイルを変更します。
%
% S = SETOUTFILE(...)は、設定ファイルのハンドルを出力し、名前の変更をフ
% ァイルに保存しません。ファイルを保存するためにはSAVESETFILE(S)を、レポ
% ートを作成するためには、GENERATEREPORT(S)を用いてください。
%
% 参考   REPORT, SETEDIT, RPTLIST, RPTCONVERT, COMPWIZ





%   Copyright (c) 1997-2001 by The MathWorks, Inc.
