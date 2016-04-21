% COUTLINE/GETRPTNAME   カレントのレポートの名前を出力
% 
%     [DIR,FILE,EXT]=GETRPTNAME(C)
% 
% レポート出力ディレクトリ名、ファイル名、拡張子の名前を出力します。
% 
%     [DIR,FILE,EXT,C]=GETRPTNAME(C)
%   
% レポート出力ディレクトリ名、ファイル名、拡張子の名前を出力します。
% また、以下のフィールドを設定します。
% 
%            c.ref.SourceFileName=DIR/FILE .sgml
%            c.ref.ReportFileName=DIR/FILE EXT;
%            c.rptcomponent.ReportDirectory=DIR;
%            c.rptcomponent.ReportFilename=FILE;
%            c.rptcomponent.ReportExt=EXT;
%
% いずれの書式でも、GETRPTNAME(C,SETFILENAME)はカレントの設定ファイル名
% を指定します。これは、レポート名またはディレクトリが設定ファイルから継
% 承されない場合に有効です。
%
% 参考   COUTLINE





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:19:22 $
%   Copyright 1997-2002 The MathWorks, Inc.
