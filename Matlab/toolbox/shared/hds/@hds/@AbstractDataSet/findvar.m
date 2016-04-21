function [v,idx] = findvar(this,varid)
%FINDVAR  Locates variable with given name.
%
%   V = FINDVAR(D,VARNAME) searches the root node for a variable
%   with name VARNAME and returns the corresponding @variable 
%   handle V.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:01 $
vars = getvars(this);
if isa(varid,'hds.variable')
   idx = find(vars==varid);
else
   idx = find(strcmp(varid,get(vars,{'Name'})));
end
if isempty(idx)
   v = [];
else
   v = vars(idx);
end