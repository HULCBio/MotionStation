% GETUPROP   ユーザ定義プロパティの値の取得
% 
% VALUE = GETUPROP(H, NAME) は、ハンドル H をもつオブジェクトの中で、
% NAME により指定される名前をもつユーザ定義のプロパティ値を取得します。
% ユーザ定義プロパティが存在しなければ、VALUE には空行列が出力されます。
%
% VALUE =GETUPROP(H) は、ハンドル番号Hをもつオブジェクトにすべてのユーザ
% 定義のプロパティを出力します。
% 
% この関数は、古い関数なので、GETTAPPDATA を代わりに使ってください。
%
% 参考： SETAPPDATA, RMAPPDATA, ISAPPDATA.


%  Steven L. Eddins, October 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:06 $
