%ERROR  メッセージの表示と関数の中止
% ERROR('MSGID', 'MESSAGE') は、文字列 MESSAGE にエラーメッッセージを表示し、
% エラーを抜けて、カレントに実行しているM-ファイルからキーボードへ制御を
% 出力します。MSGID は、エラーを一意に識別することができるメッセージ識別子
% です。メッセージ識別子は、<component>[:<component>]:<mnemonic> の形式の
% 文字列で、<component> と <mnemonic> は、英数字文字列です。
% メッセージ識別子の例は、'myToolbox:myFunction:fileNotFound' です。
% 発生したエラーの識別子は、 関数 LASTERROR によって取得することができます 
% (たとえば、CATCH ブロック内で、どの種類のエラーが発生したかを決定します)。
% MESSAGE は、\t or \n などのエスケープシークエンスを含む文字列です。ERROR は、
% これらの列を、タブや newline などの適当なテキストキャラクタに変換します。
%
% ERROR('MSGID', 'MESSAGE', A, ...) は、書式をもつエラーメッセージを表示し、
% M-ファイルを抜けます。エスケープシークエンスに加え、文字列 MESSAGE は、
% 関数 SPRINTF によりサポートされる、C 言語の変換子 (たとえば、%s または %d) 
% を含みます。追加の引数 A, ... は、これらの指定子に相当する値を提供します。
% これらの引数は、文字列、または、スカラーの数値をもつことができます。有効な
% 変換子に関する情報は、HELP SPRINTFを参照してください。
%
% ERROR('MESSAGE', A, ...) は、書式をもつエラーメッセージを表示し、
% M-ファイルを抜けます。文字列 MESSAGE は、関数 SPRINTF によりサポート
% される、 C 言語の変換子 (たとえば、%s または %d) を含みます。MSGID 
% 引数がないため、エラーに対するメッセージ識別子は、デフォルトは空文字列
% になります。
%
% ERROR('MESSAGE') は、書式なしのエラーメッセージを表示し、M-ファイルを
% 抜けます。文字列  MESSAGE に含まれるエスケープシークエンス、または、
% 変換子は、これらを表わすテキストに変換されません。MSGID 引数がないため、
% エラーに対するメッセージ識別子は、デフォルトは空文字列になります。
% 特殊な場合として、MESSAGE が空文字列の場合は、アクションは何も行われず、
% ERROR はM-ファイルを終了せずに出力されます。
%
% 注意: メッセージ識別子を使用し、書式なしのメッセージを表示するためには、
% つぎを使用してください。
%
%       ERROR('MSGID', '%s', 'MESSAGE')
%
% ERROR(MSGSTRUCT) は、MSGSTRUCT をフィールド 'message' および 'identifier' 
% をもつスカラー構造体として、つぎのように動作します。
%
%       ERROR(MSGSTRUCT.identifier, '%s', MSGSTRUCT.message);
%
% (注意: これは、メッセージフィードが書式なしで表示されることを意味します)。
% 特殊な場合として、MSGSTRUCT が空の構造体の場合、 アクションなしで
% M-ファイルから抜けずに、ERROR を出力します。
%
% 参考 RETHROW, LASTERROR, LASTERR, SPRINTF, TRY, CATCH, DBSTOP, ERRORDLG,
%      WARNING, DISP.

%   Copyright 1984-2002 The MathWorks, Inc. 
