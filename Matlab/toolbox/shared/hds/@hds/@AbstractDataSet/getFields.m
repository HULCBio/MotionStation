function f = getFields(this)
%GETFIELDS  Returns list of variable and link names.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:04 $
v = [get(this.Data_,{'Variable'});get(this.Children_,{'Alias'})];
f = get(cat(1,v{:}),{'Name'});