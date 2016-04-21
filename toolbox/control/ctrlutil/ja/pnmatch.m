% PNMATCH   プロパティリストに対して一致するプロパティ名
%
% PROPERTY = PNMATCH(NAME,PLIST) は、PLIST の中に含まれているプロパティ名
% から文字列で定義した NAME を検索します。ユニークに一致する場合、PROPERTY
% に、プロパティのフル名を出力します。他の場合は、エラーメッセージが
% 出力されます。PNMMATCH は、比較に、大文字、小文字の区別をしません。
%
% PROPERTY = PNMATCH(NAME,PLIST,N) は、最初の N 個のキャラクタを比較します。
%
% 参考 : GET, SET.


%   Author(s): P. Gahinet 4-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:38 $
