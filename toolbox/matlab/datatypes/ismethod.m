function f = ismethod(obj,name)
%ISMETHOD  True if method of object.
%   ISMETHOD(OBJ,NAME) returns 1 if string NAME is a method of object
%   OBJ, and 0 otherwise.
%
%   Example:
%     Hd = dfilt.df2;
%     f = ismethod(Hd, 'order')
%
%   See also METHODS.  
  
%   Author: Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 03:22:59 $

error(nargchk(2,2,nargin))

i = strmatch(name,methods(obj),'exact');
f = ~isempty(i);