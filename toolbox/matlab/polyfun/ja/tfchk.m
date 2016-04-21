% TFCHK   プロパーな伝達関数のチェック
%
% [NUMc,DENc] = TFCHK(NUM,DEN) は、伝達関数 NUM,DEN がプロパーの場合、
% LENGTH(NUMc) = LENGTH(DENc) となる等価な伝達関数の分子と分母を出力
% します。そうでない場合、エラーを表示します。
% コマンドラインにエラーを出力する代わりに3番目の出力にエラーメッセージ
% を返します。


%   Clay M. Thompson 6-26-90
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:01 $

