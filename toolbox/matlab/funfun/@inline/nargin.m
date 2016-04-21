function y = nargin(obj)
%NARGIN Number of input arguments to an INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:20:59 $

y = obj.numArgs;
