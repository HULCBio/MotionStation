% REGEXP   正規表現の一致
%
% START = REGEXP(STRING,EXPRESSION) は、正規表現文字列 EXPRESSION に
% 一致する STRING 内の部分文字列のインデックスを含む行ベクトル START 
% を出力します。
%
% EXPRESSION 内の以下のシンボルは、特定の意味をもちます:
%
%              シンボル   意味
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
%                  |     前の部分表現、または後の部分表現と一致
%                  \w    単語と一致 [a-z_A-Z0-9]
%                  \W    単語でないもの [^a-z_A-Z0-9]
%                  \d    数字と一致 [0-9]
%                  \D    数字でないもの [^0-9]
%                  \s    空白と一致 [ \t\r\n\f]
%                  \S    空白でないもの [^ \t\r\n\f]
%            \<WORD\>    正確に単語と一致
%
% 例題
%      str = 'bat cat can car coat court cut ct caoueouat';
%      pat = 'c[aeiou]+t';
%      regexp(str, pat)
%         出力は、 [5 17 28 35] です。
%
%      これは、cから始まって、t で終わり、その中に1つまたはそれ以上の
%      母音を含む単語に一致するインデックスの行ベクトルになります。
%
% STRING または EXPRESSION のどちらかが文字列のセル配列である場合、
% REGEXP は、インデックスの行ベクトルの M×N のセル配列を出力します。
% 
% 例題
%    str = {'Madrid, Spain' 'Romeo and Juliet' 'MATLAB is great'};
%    pat = '\s';
%    regexp(str, pat)
%       出力は、{[8]; [6 10]; [7 10]}です。
%
%    STRINGとEXPRESSIONの両方が文字列からなるセル配列の場合、REGEXPは、
%    STRINGとEXPRESSIONのシーケンシャルに一致する要素のインデックスか
%    らなる行ベクトルのセル配列です。STRINGとEXPRESSIONの要素数は、一致
%    しなければなりません。
%
% [START,FINISH] = REGEXP(STRING,EXPRESSION) は、START 内の部分文字列
% に対応する最後のキャラクタのインデックスを含む付加的な行ベクトル
% FINISH を出力します。
%
% 例題
%    str = {'Madrid, Spain' 'Romeo and Juliet' 'MATLAB is great'};
%    pat = {'\s', '\w+', '[A-Z]'};
%    regexp(str, pat)
%       出力は、{[8]; [1 7 11]; [1 2 3 4 5 6]}です。
%
%    これは、'Madrid, Spain'内の空白、'Romeo and Juliet' 内の全単語、
$    'MATLAB is great'内の大文字と一致するインデックスからなる行ベクト
%     ルのセル配列です。
%
% [START,FINISH] = REGEXP(STRING,EXPRESSION) は、START内の対応するサ
% ブ文字列の最後の文字のインデックスを含む行ベクトルFINISHを出力します。
%
% 例題
%      str = 'regexp helps you relax';
%      pat = '\w*x\w*';
%      [s,f] = regexp(str, pat)
%         出力は、以下のとおりです。
%            s = [1 18]
%            f = [6 22]
%
%      これは、文字 x を含む単語を検出します。
%
% [START,FINISH,TOKENS] = REGEXP(STRING,EXPRESSION) は、START および 
% FINISH 内の部分文字列に対応する範囲内の文字列の集合(トークン)の始ま
% りと終わりのインデックスである 1×N のセル配列 TOKENS を出力します。
% トークンは、EXPRESSION 内の括弧によって示されます。
%
% 例題
%      str = 'six sides of a hexagon';
%      pat = 's(\w*)s';
%      [s,f,t] = regexp(str, pat)
%         出力は、以下のとおりです。
%            s = [5]
%            f = [9]
%            t = {[6 8]}
%
%      これは、文字 s が含まれた部分文字列を検出します。
%
% デフォルトでは、REGEXP は、すべて一致するものを出力します。最初に一
% 致した文字を検出するには、REGEXP(STRING,EXPRESSION,'once') を使用し
% てください。一致するものが見つからない場合、START、FINISH、および 
% TOKENS は、空になります。
%
% MATCH = REGEXP(STRING, EXPRESSION, 'match') は、EXPRESSIONにより
% 一致する部分文字列からなるセル配列を出力します。
%
% MATCH = REGEXP(STRING, EXPRESSION, 'match', 'once') は、EXPRESSION
% により一致する部分文字列を出力します。
%
% TOKENS = REGEXP(STRING, EXPRESSION, 'tokens') は、EXPRESSIONの括弧
% 付きの部分表現により一致する部分文字列のセル配列からなるセル配列を出力
% します。
%
% TOKENS = REGEXP(STRING, EXPRESSION, 'tokens', 'once') は、EXPRESSION
% の括弧付きの部分表現により一致する部分文字列のセル配列を出力します。
%
% NAMES = REGEXP(STRING, EXPRESSION, 'names') は、EXPRESSIONの指定さ
% れたトークンにより一致する部分文字列からなるセル配列を出力します。指定
% したトークンは、パターン (?<name>...)により示されます。各structは、
% EXPRESSION内の指定されたトークンに対応するフィールドをもち、それらの
% フィールドは、EXPRESSION内の指定されたトークンと一致する部分文字列を含
% みます。
%
% REGEXP は、international character sets をサポートしていません。
%
% 参考:  REGEXPI, REGEXPREP, STRCMP, STRFIND, FINDSTR, STRMATCH.



%
%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:06:58 $
