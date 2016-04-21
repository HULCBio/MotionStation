%NARGCHK 入力引数の数のチェック
% MSGSTRUCT = NARGCHK(LOW,HIGH,N,'struct') は、N が LOW と HIGH の間
% でなければ、適切なエラーメッセージ構造体を出力します。N が 指定範囲
% にある場合は、メッセージ構造体は空になります。メッセージ構造体は、
% 少なくとも2つのフィールド、'message' と 'identifier' をもちます。
%
% MSG = NARGCHK(LOW,HIGH,N) は、N が LOW と HIGH の間でなければ、
% 適切なエラーメッセージ文字列を出力します。N が 指定範囲にある場合は、
% NARGCHK は空行列を出力します。
%
% MSG = NARGCHK(LOW,HIGH,N,'string') は、MSG = NARGCHK(LOW,HIGH,N) と
% 同じです。
% 
% 例題
%    error(nargchk(1, 3, nargin, 'struct'))
%
% 参考 NARGOUTCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2002 The MathWorks, Inc. 
