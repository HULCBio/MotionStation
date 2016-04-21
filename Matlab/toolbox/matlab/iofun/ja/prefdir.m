% PREFDIR 優先権をもつディレクトリ名
% 
% D = PREFDIR(CREATEIFNECESSARY) は、プラットフォーム固有の優先権をもつ
% ディレクトリ名を出力します。ここには、mexopts.bat などのユーザ定義
% ツールの補助ファイルが含まれています。
%
% D = PREFDIR(1) は、ディレクトリが存在しない場合は作成します。
% 
% D = PREFDIR または D = PREFDIR(0) は、存在を確認せずに、ディレクトリ
% 名を出力します。
%
% 参考：GETPREF, SETPREF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:23 $
