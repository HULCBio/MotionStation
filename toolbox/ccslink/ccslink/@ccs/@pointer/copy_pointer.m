function dummy = copy_pointer(pp,resp)
%   Private. Copies over PP properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/11/30 23:10:21 $


% public properties

resp.reftype     = pp.reftype;
resp.referent    = pp.referent;

% private properties

resp.isrecursive = pp.isrecursive;


% [EOF] copy_pointer.m
