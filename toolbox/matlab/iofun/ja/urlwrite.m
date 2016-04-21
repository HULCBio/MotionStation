% URLWRITE    URLの内容をファイルに保存
%
% URLWRITE(URL,FILENAME) は、URLの内容をファイルに保存します。FILENAME 
% は、ファイルの完全なパスを指定することができます。単なる名前の場合は、
% カレントディレクトリ内に作成されます。
%
% F = URLWRITE(...) は、ファイルのパスを出力します。
%
% F = URLWRITE(...,METHOD,PARAMS) は、情報をリクエストの一部としてサーバ
% に渡します。'method' は 'get' または 'post' で、PARAMS はパラメータと値
% の組からなるセル配列です。
%
% [F,STATUS] = URLWRITE(...) は、エラーをキャッチし、エラーコードを出力
% します。
%
% 例題:
%    urlwrite('http://www.mathworks.com/',[tempname '.html'])
%    urlwrite('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt','cleve.txt')
%    urlwrite('file:///C:\winnt\matlab.ini',fullfile(pwd,'my.ini'))
%
% ファイヤーウォール内からの利用の場合は、プリファレンスでプロキシサーバ
% を設定してください。
% 
% 参考 ： URLREAD.


%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.
