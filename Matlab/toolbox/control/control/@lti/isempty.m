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
 
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.11 $  $Date: 2002/04/10 05:50:32 $

boo = any(size(sys)==0);

