% LASTERR   最新のエラーメッセージの出力
%
% LASTERR 自身は、MATLABが出力した最新のエラーメッセージを含む文字列
% を出力します。
%
% [LASTMSG, LASTID] = LASTERR は、2つの文字列を出力します。1つ目は
% MATLABが出力する最新のエラーメッセージを含み、2つ目はそれに対応する
% メッセージ識別子文字列を含みます(メッセージ識別子に関する情報は、HELP 
% ERROR を参照してください)。
%
% LASTERR('') は、関数 LASTERR をリセットして、LASTMSG と LASTID に対し
% てつぎのエラーが生じるまで空行列を出力します。
% 
% LASTERR('MSG', 'MSGID') は、最新のエラーメッセージを MSG に設定し、最
% 新のエラーメッセージ識別子を MSGID に設定します。MSGID は、有効なメッ
% セージ識別子(または空文字列)でなければなりません。
%
% LASTERRは、通常、EVAL の2引数の書式 EVAL('try','catch')、または TRY...
% CATCH...END ステートメントと共に使用されます。catchの挙動は、文字列
% LASTERR メッセージ識別子(またはメッセージ文字列)を調べてエラーの原因
% を求め、適切な処置を示すことができます。
%
% 参考：LASTERROR, ERROR, LASTWARN, EVAL, TRY, CATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 01:59:11 $
%   Built-in function.


