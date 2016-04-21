function	num = find_formatter_type(str)
%FIND_CAPTION_TYPE Find the enumeration value from the enumeration string

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/03/23 02:59:32 $

persistent Caption_Type_Strings Caption_Type_Values;

if isempty(Caption_Type_Strings)
	[prop,names]=cv('subproperty','formatter.keyNum');
	[Caption_Type_Strings,I]=sort(names{1});
	Caption_Type_Values = I-1;
end

% WISH with an ordered set of strings we could do something
% more sophisticated but for now just do a brute force search

testCell{1} = str;
Match = strcmp(testCell,Caption_Type_Strings);
Index = find(Match);
if isempty(Index),
    error('No formatters matches string');
end
if length(Index)>1,
    error('More than 1 formatter matches string');
end
num = Caption_Type_Values(Index);
