% DBTYPE   ライン番号を付けてM-ファイルをリスト
% 
% DBTYPEは、ユーザがブレークポイントを設定し易いように、ライン番号を付け
% てM-ファイル関数をリストします。このコマンドには、つぎの2つの形式があ
% ります。
%
%    DBTYPE MFILE
%    DBTYPE MFILE start:end
%
% ここで、MFILEは、M-ファイル関数名で、startとendはライン番号です。
%
% DBTYPE FILENAMEは、フルパス名またはMATLABPATHの相対部分パス名を
% もつファイルの内容をリストします(PARTIALPATHを参照)。
%
% 参考：DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBSTACK, DBUP, DBDOWN,
%       DBSTATUS, DBQUIT, PARTIALPATH.


%   Steve Bangert, 6-25-91.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:45:38 $
%   Built-in function.

