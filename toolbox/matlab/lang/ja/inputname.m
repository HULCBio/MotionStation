% INPUTNAME   入力引数名
% 
% ユーザ定義関数の本体内で、INPUTNAME(ARGNO) は、引数の番号 ARGNO に
% 対するワークスペース変数名を出力します。入力引数に名前がない場合
% (たとえば、a(1), varargin{:}, eval(expr) 等のような計算の結果である
% とき)は、INPUTNAME は空文字列を出力します。
%
% 例題: 
% 関数 myfun がつぎのように定義されていると仮定します。
% 
%   function y = myfun(a,b)
%   disp(sprintf('My first input is "%s".',inputname(1)))
%   disp(sprintf('My second input is "%s".',inputname(2)))
% 
% このとき、
% 
%   x = 5; myfun(x,5)
% 
% は、つぎのような出力をします。
% 
%     My first input is "x".
%     My second input is "".
%
% 参考：NARGIN, NARGOUT, NARGCHK, MFILENAME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:06 $
%   Built-in function.
