function r = rsmd(c)
%RSMD Construct resultset metadata object.
%   R = RSMD(C) returns a result set meta data object given a cursor 
%   object or result set object, C.
%
%   See also GET.

%   Author: C.F.Garvin, 07-10-98
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $	$Date: 2004/04/06 01:05:45 $%

%Create parent object for generic methods
dbobj = dbtbx;
if nargin == 0
  s.Handle = [];
  r  = class(s,'rsmd',dbobj);
  return
end

%Check for valid cursor or resultset input
x = class(c);
if strcmp(x,'cursor')
  c = resultset(c);
  x = class(c);
end

if ~any(strcmp(x,'resultset'))
  error('database:rsmd:invalidInput','Input argument is not a RESULTSET or CURSOR object.')
end

%Build result set structure from cursor
tmp = struct(c); 
s.Handle = getMetaData(tmp.Handle);

%Set class
r = class(s,'rsmd',dbobj);
