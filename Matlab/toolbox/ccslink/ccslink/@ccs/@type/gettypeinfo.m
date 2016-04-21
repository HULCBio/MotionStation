function resp = gettypeinfo(td,typename)
% Returns info on an existing type entry in the type class.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:59 $

error(nargchk(2,2,nargin));
if ~ischar(typename),
    error('Second parameter must be a Type string. ');
end

matchfound = strmatch(typename,td.typename,'exact');
if matchfound,
   resp = td.typelist{matchfound}.basetype;
else
    error(['Typedef ''' typename ''' does not exist in the list. ']);
end

% [EOF] gettypeinfo.m