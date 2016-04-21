% LASTWARN   最新のワーニングメッセージ
% 
% LASTWARN 自身では、MATLABが出力した最新のワーニングメッセージを含む
% 文字列を出力します。
%
% [LASTMSG, LASTID] = LASTWARN は、は、2つの文字列を出力します。1つ目は
% MATLABが出力する最新のワーニングメッセージを含み、2つ目はメッセージ
% 識別子に対応する最新のワーニングメッセージを含みます(メッセージ識別子
% に関する情報は、HELP WARNING を参照してください)。
%
% LASTWARN('')は、関数 LASTWARN をリセットして、LASTMSG と LASTID に
% 対してつぎのワーニングが生じるまで空行列を出力します。
% 
% LASTWARN('MSG', 'MSGID') は、最新のワーニングメッセージを MSG に設定
% し、最新のワーニングメッセージ識別子をMSGID に設定します。MSGID は、
% 有効なメッセージ識別子(または空文字列)でなければなりません。
%
% 関数 WARNING は、呼び出されたワーニングがその時点でオンであるかオフで
% あるかどうかに関わらず、LASTWARN の状態を更新します。
%
% 参考：WARNING, LASTERR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:13 $
%   Built-in function.
