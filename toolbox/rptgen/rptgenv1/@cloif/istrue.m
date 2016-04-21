function tf=istrue(c)
%ISTRUE returns whether or not the component's conditional string is true

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:10 $

tf=evalin('base',...
   c.att.ConditionalString,...
   'logical(0)');