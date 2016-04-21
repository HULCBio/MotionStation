% VARARGIN   可変の入力引数の一覧
% 
% 関数に対して、任意の数の引数を与えることができます。変数 VARARGIN
% は、関数のオプション引数を含むセル配列です。VARARGIN は、最新の入
% 力引数として宣言され、その点より先のすべての入力をまとめます。宣言の
% 中では、VARARGINは小文字でなければなりません(すなわち、varargin)。
%
% たとえば、関数
%
%     function myplot(x,varargin)
%     plot(x,varargin{:})
%
% は、2番目の引数以降の入力を、変数"varargin"にまとめます。MYPLOT は、
% カンマで区切られたシンタックス varargin{:} を使って、オプションの
% パラメータをplotに渡します。
%
%     myplot(sin(0:.1:1),'color',[.5 .7 .3],'linestyle',':')
%
% は、'color'、[.5 .7 .3]、'linestyle'、':'を要素とする1行4列のセル配列
% varargin を出力します。
% 
% 参考：VARARGOUT, NARGIN, NARGOUT, INPUTNAME, FUNCTION, LISTS, PAREN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:33 $
%   Built-in function.

