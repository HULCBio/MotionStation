% REGEXPREP   正規表現を使って文字列の置き換え
%
% S = REGEXPREP(STRING,EXPRESSION,REPLACE) は、STRING 内の文字列の正規
% 表現 EXPRESSION に相当するものすべてを文字列 REPLACE に置き換えます。
% 新しい文字列として出力されます。REGEXPREP に一致するものが見つからな
% い場合、STRING は変更されずに出力されます。
%
% STRING、EXPRESSION または、REPLACE が、任意の文字列のセル配列である
% 場合、REGEXPREP は、L×M×N の文字列のセル配列を出力します。ここで、
% L は、STRING 内の文字列の数、M は、EXPRESSION 内の正規表現の数、N は
% REPLACE 内の文字列の数です。
%
% デフォルトで、REGEXPREP は、大文字、小文字すべてに一致する文字列を
% 置き換え、文字列の集合(トークン)を使用しません。可能なオプションは
% 以下のとおりです。
%
%      'ignorecase'   - EXPRESSION が、STRING に一致するキャラクタの
%                       場合は無視します。
%      'preservecase' - ('ignorecase' により)、一致する場合は無視しますが、
%                       置き換えるときに、STRING 内に対応するキャラクタの
%                       場合は、REPLACE キャラクタを上書き処理します。
%      'once'         - STRING 内の EXPRESSION に最初に相当する文字列
%                       のみ置き換えます。
%      N              - STRING 内の EXPRESSION に相当する N番目の文字列
%                       のみ置き換えます。
%
% REGEXPREP は、international character sets をサポートしていません。
%
% 例題:
%    str = 'My flowers may bloom in May';
%    pat = 'm(\w*)y';
%    regexprep(str, pat, 'April')
%       出力は、'My flowers April bloom in May' です。
%
%    regexprep(str, pat, 'April', 'preservecase')
%       出力は、'April flowers april bloom in April' です。
%
%    str = 'I walk up, they walked up, we are walking up, she walks.'
%    pat = 'walk(\w*) up'
%    regexprep(str, pat, 'ascend$1')
%       出力は、'I ascend, they ascended, we are ascending, she walks.'
%       です。
%
% 参考:  REGEXP, REGEXPI, STRREP, STRCMP, STRNCMP, FINDSTR, STRMATCH.


%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:07:00 $
