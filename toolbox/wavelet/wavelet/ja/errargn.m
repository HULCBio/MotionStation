% ERRARGN　 関数の引数の数のチェック
%
% ERR = ERRARGN('function',NUMARGIN,ARGIN,NUMARGOUT,ARGOUT) 、または
% [ERR,MSG] = ERRARGN('function',NUMARGIN,ARGIN,NUMARGOUT,ARGOUT) は、
% 指定された関数の入力 ARGIN の数、または、出力 ARGOUT の数が、
% (NUMARGIN 及び NUMARGOUT によって) それぞれ可能な値のベクトルに
% 属さない場合、1を出力します。この場合、MSG は、適切なエラー
% メッセージを含みます。それ以外では、ERRARGN は、 ERR = 0 と MSG = []
% を出力します。
%
% 参考： ERRARGT.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Copyright 1995-2002 The MathWorks, Inc.

