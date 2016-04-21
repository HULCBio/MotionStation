% URLREAD    URLの内容を文字列として出力
%
%  S = URLREAD('URL') は、URLの内容を文字列 S に読み込みます。サーバがバ
% イナリデータを出力する場合は、文字列にはガーベージが含まれます。
%
%  S = URLREAD('URL','method',PARAMS) は、情報をリクエストの一部としてサー
% バに渡します。'method' は 'get' または 'post' で、PARAMS はパラメータと値の
% 組からなるセル配列です。
%
% [S,STATUS] = URLREAD(...) は、エラーをキャッチし、ファイルのダウンロードに
% 成功した場合は 1 を、それ以外は 0 を返します。
%
% 例題:
%    s = urlread('http://www.mathworks.com');
%    s = urlread('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt')
%    s = urlread('file:///C:\winnt\matlab.ini')
%
% ファイヤーウォール内からの利用の場合は、プリファレンスでプロキシサーバ
% を設定してください。
% 
% 参考 ： URLWRITE.


%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.

