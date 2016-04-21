function boo = isempty(sys)
%ISEMPTY  True for empty LTI models.
%
%   ISEMPTY(SYS) returns 1 (true) if the LTI model SYS has 
%   no input or no output, and 0 otherwise.
%
%   For LTI arrays, ISEMPTY(SYS) is true if the array has
%   empty dimensions, or the LTI models themselves are empty.
%
%   See also SIZE, ISSISO, LTIMODELS.
 
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/10 23:13:09 $
boo = any(size(sys)==0) || size(sys,'freq')==0;

