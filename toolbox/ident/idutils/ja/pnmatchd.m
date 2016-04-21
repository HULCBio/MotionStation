% PNMATCH  プロパティ名の比較
%
% PROPERTY = PNMATCH(NAME,PLIST) は、PLIST の中に含まれているプロパティ
% 名のリストから文字列 NAME と一致するものを求めます。ユニークな一致が見
% られると、PROPERTY には、一致したプロパティのフル名が出力されます。そ
% の他の場合、エラーメッセージが出力されます。PNMATCH は、大文字、小文字
% の区別も行います。
%
% PROPERTY = PNMATCH(NAME,PLIST,N) は、最初の N キャラクタに限定して比較
% を行います。
% 
% 参考： GET, SET.

%   Copyright 1986-2001 The MathWorks, Inc.
