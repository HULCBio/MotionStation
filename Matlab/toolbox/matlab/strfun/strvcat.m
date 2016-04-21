function s=strvcat(varargin)
%STRVCAT Vertically concatenate strings.
%   S = STRVCAT(T1,T2,T3,..) forms the matrix S containing the text
%   strings T1,T2,T3,... as rows.  Automatically pads each string with
%   blanks in order to form a valid matrix. Each text parameter, Ti, can
%   itself be a string matrix.  This allows the creation of arbitrarily
%   large string matrices.  Empty strings in the input are ignored.
%
%   S = STRVCAT(C), when C is a cell array of strings, passes each
%   element of C as an input to STRVCAT.  Empty strings in the input are 
%   ignored.
%
%   STRVCAT('Hello','Yes') is the same as ['Hello';'Yes  '] except
%   that the padding is done automatically.
%
%   See also CELLSTR, CHAR, STRCAT.

%   Clay M. Thompson  3-20-91
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.25.4.2 $  $Date: 2004/04/16 22:08:54 $

numinput = nargin;
if numinput == 1 && iscellstr(varargin{1})
  varargin = (varargin{1});
end
% find the empty cells 
notempty = ~cellfun('isempty',varargin);
% vertically concatenate the non-empty cells.
s = char(varargin{notempty});


