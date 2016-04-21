% FINDOBJ   指定したプロパティ値をもつオフジェクトの検出
% 
% H = FINDOBJ('P1Name',P1Value,...) は、FINDOBJ コマンドに渡されるパラ
% メータと値の組と一致するプロパティ値をもつ、ルートレベルとそれより
% 下位のオブジェクトのハンドル番号を出力します。
%
% H = FINDOBJ(ObjectHandles、'P1Name'、P1Value,...) は、ObjectHandles 
% とその子にリストされたオブジェクトに検索を制限します。
%
% H = FINDOBJ(ObjectHandles、'flat'、'P1Name'、P1Value,...) は、
% ObjectHandles にリストされたオブジェクトのみに検索を制限します。この
% オブジェクトの子は検索しません。
%
% H = FINDOBJ は、ルートオブジェクトとその下位にあるすべてのオブジェクト
% のハンドル番号を出力します。
%
% H = FINDOBJ(ObjectHandles) は、ObjectHandles にリストされたハンドル番号
% と、それらのすべての子のハンドル番号を出力します。
%
% 参考：SET, GET, GCF, GCA.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:42 $
%   Built-in function.

