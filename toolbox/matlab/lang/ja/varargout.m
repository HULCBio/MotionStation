% VARARGOUT   可変の出力引数の一覧
% 
% 関数に任意の数の出力引数を設定することができます。変数VARARGOUT は、
% 関数のオプションの出力引数を含むセル配列です。VARARGOUT は、最新の
% 出力引数として宣言され、その点より先のすべての出力をまとめます。
% 宣言の中では、VARARGOUT は小文字でなければなりません(すなわち、varargout)。
% 
% VARARGOUTは、関数が呼び込まれるときに初期化されません。関数がリターン
% する前に、VARARGOUTを作成しなければなりません。作成される出力の数を
% 決定するためには、NARGOUT を使ってください。
%
% たとえば、関数
%
%     function [s,varargout] = mysize(x)
%     nout = max(nargout,1)-1;
%     s = size(x);
%     for i = 1:nout、varargout(i) = {s(i)}; end
%
% は、サイズベクトルとオプションで各々のサイズを出力します。そのため
%
%    [s,rows,cols] = mysize(rand(4,5));
%
% は、s = [4 5]、rows = 4、cols = 5 を出力します。
%
% 参考：VARARGIN, NARGIN, NARGOUT, FUNCTION, LISTS, PAREN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:34 $
%   Built-in function.
