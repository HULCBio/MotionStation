function var2par(this,x)
% Converts decision variable data back into parameter data.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:37 $
offset = 0;
p = this.Project.Parameters;

% Set estimated elements of the parameter objects from the vector X.
for ct=1:length(p)
   pct = p(ct);
   idxt = find(pct.Tuned);
   len = length(idxt);
   if len>0
      pct.Value(idxt) = x(offset+1:offset+len);
      offset = offset + len;
   end
end
