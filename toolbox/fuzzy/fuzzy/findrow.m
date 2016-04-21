function rowNum=findrow(str,strMat)
%FINDROW Find the rows of a matrix that match the input string.
%   ROWNUM = FINDROW(STR,STRMAT) returns the index to the row or rows
%   in the matrix STRMAT that are identical to the vector STR.
%   Blanks (ASCII 32) and zeros are not considered. An empty matrix 
%   is returned if there is no match.
%
%   For example:
%
%   strMat = fstrvcat('one','fish','two','fish',[1 2 3 4 5 6]);
%   rowNum = findrow('fish',strMat)

%   Ned Gulley, 4-26-94
%   P. Gahinet 10-99
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/14 22:19:49 $

% Remove leading and trailing blanks form STR
str = fliplr(deblank(fliplr(deblank(str))));

% Initialize boolean vector that picks matching rows
nrows = size(strMat,1);
IsMatching = zeros(1,nrows);

% Process each row
for ctrow=1:nrows,
   % Remove leading and trailing blanks
   s = fliplr(deblank(fliplr(deblank(char(strMat(ctrow,:)))))); 
   IsMatching(ctrow) = strcmp(str,s);
end

rowNum = find(IsMatching);


