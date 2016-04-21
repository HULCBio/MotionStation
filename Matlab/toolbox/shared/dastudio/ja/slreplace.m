% SLREPLACE   オブジェクトの検索と置換の実行
%
% SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR' ) 
% 指定されたオブジェクト内のすべてを置換
%
% SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  
% 指定されたオブジェクトによって親となるオブジェクトの階層内にあるすべてを
% 置換
%
% OBJECTS = SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR' )  
% 指定されたオブジェクトのすべてを置換し、変更された場合のオブジェクトを
% 出力
%
% OBJECTS = SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  
% 指定されたオブジェクトによって親となるオブジェクトの階層内にあるすべてを
% 置換し、変更されたすべてのオブジェクトのベクトルを出力
%
% SLREPLACE 
% 対話型のSearch & Replaceツールを引数なしで開く


%	J Breslau
%   Copyright 1995-2002 The MathWorks, Inc.
    