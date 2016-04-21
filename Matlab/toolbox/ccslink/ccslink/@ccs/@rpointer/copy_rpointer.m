function dummy = copy_rpointer(rp,resp)
%   Private. Copies over RP properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/11/30 23:11:57 $

% public properties

resp.reftype     = rp.reftype;
resp.referent    = rp.referent;

% private properties

resp.isrecursive = rp.isrecursive;


% [EOF] copy_rpointer.m
