function this = spreadsheet(vars)
%SPREADSHEET  Constructs instance of @spreadsheet class.
%
%   S = HDS.SPREADSHEET(VARS) constructs a new spreasheet with 
%   the variables VARS as columns.  The arguments VARS and
%   LINKS are either cell arrays of variable names, or vectors
%   of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:38 $

% Create instance
this = hds.spreadsheet;

% Parse inputs
ni = nargin;
if ni>1
   error('SPREASHEET constructor takes between zero and one argument.')
end
if ni<1
   vars = [];
end

% Convert variables to @variable instances
if isa(vars,'char')
   V = hds.variable(vars);
elseif isa(vars,'cell')
   V = handle(zeros(size(vars)));
   for ct=1:length(vars)
      V(ct) = hds.variable(vars{ct});
   end
else
   V = vars;
end
for ct=1:length(V)
   this.addvar(V(ct));
end
