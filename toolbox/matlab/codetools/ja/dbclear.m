%DBCLEAR ブレークポイントの削除
% DBCLEAR コマンドは、対応する DBSTOP により設定されるブレークポイントを
% 削除します。このコマンドには、つぎのような、いくつかの形式があります。
%
%   (1)  DBCLEAR IN MFILE AT LINENO
%   (2)  DBCLEAR IN MFILE AT SUBFUN
%   (3)  DBCLEAR IN MFILE
%   (4)  DBCLEAR IF ERROR
%   (5)  DBCLEAR IF CAUGHT ERROR
%   (6)  DBCLEAR IF WARNING
%   (7)  DBCLEAR IF NANINF  または  DBCLEAR IF INFNAN
%   (8)  DBCLEAR IF ERROR IDENTIFIER
%   (9)  DBCLEAR IF CAUGHT ERROR IDENTIFIER
%   (10) DBCLEAR IF WARNING IDENTIFIER
%   (11) DBCLEAR ALL
%
% MFILE は、M-ファイル名、または、MATLABPATH-相対部分パス名 
% (PARTIALPATH を参照)である必要があります。LINENO は、MFILE 内の
% ライン数であり、SUBFUNは、MFILE 内のサブ関数名です。IDENTIFIER は、
% MATLAB Message Identifier (message identifiers については、ERROR の
% ヘルプを参照 ) です。キーワード AT および IN は、オプションです。
% 
% 上記の形式は、つぎのように動作します。
%
%   (1)  MFILE のライン LINENO のブレークポイントを削除します。
%   (2)  MFILE の指定されたサブ関数の最初の実行可能なラインでブレークポイント
%　　　　を削除します。
%   (3)  MFILE 内のすべてのブレークポイントを削除します。
%   (4)  設定されている場合、DBSTOP IF ERROR ステートメント および 
%        DBSTOP IF ERROR IDENTIFIER ステートメントを消去します。
%   (5)  設定されている場合、DBSTOP IF CAUGHT ERROR ステートメント 
%        および DBSTOP IF CAUGHT ERROR IDENTIFIER ステートメントを消去します。
%   (6)  設定されている場合、DBSTOP IF WARNING ステートメント および 
%        DBSTOP IF WARNING IDENTIFIER ステートメントを消去します
%   (7)  無限大 と NaNs のDBSTOP を設定されている場合、消去します。
%   (8)  指定したIDENTIFIER に対する DBSTOP IF ERROR IDENTIFIER 
%        ステートメントを消去します。
%        DBSTOP IF ERROR または DBSTOP IF ERROR ALL が設定されている場合、
%        指定した識別子のこの設定を消去すると、エラーになります。 
%   (9)  指定したIDENTIFIER に対するDBSTOP IF CAUGHT ERROR IDENTIFIER 
%        ステートメントを消去します。 DBSTOP IF CAUGHT ERROR または 
%        DBSTOP IF CAUGHT ERROR ALLが設定されている場合、指定した識別子の
%        この設定を消去すると、エラーになります。 
%   (10) 指定されたIDENTIFIER に対する DBSTOP IF WARNING IDENTIFIER ステート
%        メントを消去します。
%        IDENTIFIER. DBSTOP IF WARNING または DBSTOP IF WARNING ALL が設定
%        されている場合、指定した識別子のこの設定を消去するとエラーになります。
%   (11) 上記の(4)-(7)に述べたように、すべてのM-ファイルのブレークポイント
%        を消去します。
%
% 参考 DBSTEP, DBSTOP, DBCONT, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%      DBQUIT, ERROR, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
