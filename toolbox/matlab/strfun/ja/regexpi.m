% REGEXPI   場合によらない正規表現の一致
%
% START = REGEXPI(STRING,EXPRESSION) は、場合にかかわらず、正規表現の
% 文字列 EXPRESSION と一致する STRING 内の部分文字列のインデックスを含
% む行ベクトル START を出力します。
%
% EXPRESSION 内の以下のシンボルは、特定の意味をもちます:
%
%              シンボル  意味
%              --------  --------------------------------
%                  ^     文字の始まり
%                  $     文字の最後
%                  .     任意のキャラクタ
%                  \     つぎの文字列の引用
%                  *     0回以上で一致
%                  +     1回以上で一致するか、すべて一致
%                  ?     0回、または1回以上一致するか、最小回数で一致
%                  {}    ある範囲で一致
%                  []    キャラクタの設定
%                  [^]   キャラクタの設定を除く
%                  ()    グループの部分正規表現
%                  |     前のサブ表現、または後のサブ表現と一致
%                  \w    単語と一致 [a-z_A-Z0-9]
%                  \W    単語でないもの [^a-z_A-Z0-9]
%                  \d    数字と一致 [0-9]
%                  \D    数字でないもの [^0-9]
%                  \s    空白と一致 [ \t\r\n\f]
%                  \S    空白でないもの [^ \t\r\n\f]
%             <WORD\>    正確に単語と一致
%
% 例題
%      str = 'My flowers may bloom in May';
%      pat = 'm\w*y';
%      regexpi(str, pat)
%         出力は、[1 12 25] です。
%
%      これは、場合にかかわらず、m で始まって y で終わる単語に一致する
%      インデックスの行ベクトルになります。
%
% STRING または、EXPRESSION は、文字列のセル配列のいずれかである場合、
% REGEXPI は、インデックスの行ベクトルの M×N のセル配列を出力します。
%
% STRINGとEXPRESSIONの両方が文字列からなるセル配列の場合、REGEXPI は、
% STRINGとEXPRESSIONのシーケンシャルに一致する要素のインデックスの行ベク
% トルからなるセル配列を出力します。STRINGとEXPRESSIONの要素数は、一致
% しなければなりません。
%
% [START,FINISH] = REGEXPI(STRING,EXPRESSION) は、START 内の部分文字列
% に対応する最後のキャラクタのインデックスを含む付加的な行ベクトル
% FINISH を出力します。
%
% [START,FINISH,TOKENS] = REGEXPI(STRING,EXPRESSION) は、START および 
% FINISH 内の部分文字列に対応する範囲内の文字列の集合(トークン)の始ま
% りと終わりのインデックスである 1×N のセル配列 TOKENS を出力します。
% トークンは、EXPRESSION 内の括弧によって示されます。
%
% デフォルトでは、REGEXPI は、一致するものをすべて出力します。最初に一
% 致した文字を検出するには、REGEXPI(STRING,EXPRESSION,'once') を使用し
% てください。一致するものが見つからない場合、START、FINISH、および 
% TOKENS は、空になります。
%
% MATCH = REGEXPI(STRING, EXPRESSION, 'match') は、EXPRESSIONにより
% 一致する部分文字列からなるセル配列を出力します。
%
% MATCH = REGEXPI(STRING, EXPRESSION, 'match', 'once') は、EXPRESSION
% により一致する部分文字列を出力します。
%
% TOKENS = REGEXPI(STRING, EXPRESSION, 'tokens') は、EXPRESSIONの括弧
% 付きの部分表現により一致する部分文字列のセル配列からなるセル配列を出力
% します。
%
% TOKENS = REGEXPI(STRING, EXPRESSION, 'tokens', 'once') は、EXPRESSION
% の括弧付き部分表現により一致する部分文字列からなるセル配列を出力します。
%
% NAMES = REGEXPI(STRING, EXPRESSION, 'names') は、EXPRESSIONの指定され
% たトークンと一致する部分文字列からなるstruct配列を出力します。指定した
% トークンは、パターン(?<name>...)により示されます。各structは、
% EXPRESSION内の指定されたトークンに対応するフィールドをもち、それらの
% フィールドは、EXPRESSION内の指定されたトークンと一致する部分文字列を含
% みます。
%
% REGEXPI は、international character sets をサポートしていません。
%
% 参考:  REGEXP, REGEXPREP, STRCMPI, STRFIND, FINDSTR, STRMATCH.
%



%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:06:59 $
