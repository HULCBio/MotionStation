function str = leadblnk(str,char)

%LEADBLNK  Deletes leading characters common to all rows of a string matrix
%
%  s = LEADBLNK(s0) deletes the leading spaces common to all
%  rows of a string matrix.
%
%  s = LEADBLNK(s0,char) deletes the leading characters corresponding
%  to the scalar char.
%
%  See also  NUM2STR, SHIFTSPC

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:18:40 $

if nargin < 1
    error('Incorrect number of arguments')
elseif nargin == 1
    char = [];
end

%  Empty argument tests

if isempty(str);    return;       end
if isempty(char);   char = ' ';   end

%  Eliminate null characters

indx = find(str==0);
if ~isempty(indx);   str(indx) = char;  end

%  Eliminate leading spaces

if size(str,1) ~= 1;      spaces = sum(str ~= char);    %  Not spaces in each row
     else;                spaces = (str ~= char);       %  Single string entry
end

indx = min(find(spaces~=0));           %  0 sum column-wise means char is in every row
if isempty(indx);  indx = length(spaces)+1;  end    %  All char in matrix
str(:,1:(indx-1)) = [];
