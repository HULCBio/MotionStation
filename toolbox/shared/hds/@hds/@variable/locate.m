function idx = locate(VarPool,vars)
%LOCATE  Locates variables in a given list.
%
%   IDX = LOCATE(VARPOOL,VARS) returns an index vector IDX
%   such that VARS = VARPOOL(IDX).  VARPOOL is a vector of
%   @variable objects, and VARS can be specified as a list 
%   of names or vector of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:41 $
nvars = length(vars);
if isa(vars,'handle')
   % Handle- based matching
   [ia,ib] = utIntersect(VarPool,vars);
else
   if isa(vars,'char')
      vars = {vars};   nvars = 1;
   end
   h = hds.VariableManager;
   v = handle(zeros(nvars,1));
   for ct=1:nvars
      v(ct) = h.findvar(vars{ct});
   end
   [ia,ib] = utIntersect(VarPool,v);
end
[ib,is] = sort(ib);
idx = ia(is);

if length(idx)~=nvars
   iv = 1:nvars;
   iv(ib) = [];
   if isa(vars,'cell')
      vname = vars{iv(1)};
   else
      vname = vars(iv(1)).Name;
   end
   error(sprintf('Unknown variable %s.',vname))
end