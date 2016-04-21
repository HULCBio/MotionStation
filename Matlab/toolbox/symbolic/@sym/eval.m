function s = eval(x);
%EVAL  Evaluate a symbolic expression.
%   EVAL(S) evaluates the character representation of the
%   symbolic expression S in the caller's workspace.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/15 03:08:39 $

s = evalin('caller',map2mat(char(x)));

%-------------------------

function r = map2mat(r)
% MAP2MAT Maple to MATLAB string conversion.
%   MAP2MAT(r) converts the Maple string r containing
%   matrix, vector, or array to a valid MATLAB string.
%
%   Examples: map2mat(matrix([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(array([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(vector([[a,b,c,d]])  returns
%             [a,b,c,d]

% Deblank.
r(findstr(r,' ')) = [];
% Remove matrix, vector, or array from the string.
r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
r = strrep(r,']])',']'); r = strrep(r,'])',']');
% Special case of the empty matrix or vector
if strcmp(r,'vector([])') | strcmp(r,'matrix([])') | ...
   strcmp(r,'array([])')
r = [];
end
