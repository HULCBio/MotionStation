% WFINDOBJ 　指定されたプロパティ値をもつオブジェクトの検索
% H = WFINDOBJ('P1Name',P1Value,...) は、WFINDOBJ コマンドに、'P1Name' と P1Va-
% lue のようなパラメータ値の組で入力されたプロパティ値と一致するプロパティ値をも
% つルートレベルで、オブジェクトとそのプロパティ値以下のオブジェクトのハンドル番
% 号を出力します。
% 
% H = WFINDOBJ(ObjectHandles、'P1Name'、P1Value,...) は、ObjectHandles に記載さ
% れたオブジェクトとその下層構成のみを対象に検索を行います。
% 
% H = WFINDOBJ(ObjectHandles、'flat'、'P1Name'、P1Value,...) は、ObjectHandles 
% に記載されたオブジェクトのみを対象に検索を行います。ここでは、下層構成物に対す
% る検索は行いません。
% 
% H = WFINDOBJ は、ルートオブジェクトのハンドル及びその下層構成物すべてを出力し
% ます。
% 
% H = WFINDOBJ(ObjectHandles) は、ObjectHandles に記載されたハンドルとそれらの下
% 層構成物すべてのハンドルを出力します。
%
% H = WFINDOBJ('figure','P1Name',P1Value,...) は、H = WFINDOBJ(get(0,'Child...
% ren'),'flat'、'P1Name'、P1Value,...) と等価です。



%   Copyright 1995-2002 The MathWorks, Inc.
