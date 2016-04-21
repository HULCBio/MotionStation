function this = dataset(vars,links)
%DATASET  Constructs instance of @dataset class.
%
%   D = HDS.DATASET(VARS,LINKS) constructs a new dataset with 
%   variables VARS and data links LINKS (a data link is a 
%   gateway to dependent data sets).  The arguments VARS and
%   LINKS are either cell arrays of variable names, or vectors
%   of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:19 $

% Create instance
this = hds.dataset;

% Parse inputs
ni = nargin;
if ni>2
   error('DATASET constructor takes between zero and two arguments.')
end
if ni<1
   vars = [];
end
if ni<2
   links = [];
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

% Convert links to @variable instances
if isa(links,'char')
   L = hds.variable(links);
elseif isa(links,'cell')
   L = handle(zeros(size(links)));
   for ct=1:length(links)
      L(ct) = hds.variable(links{ct});
   end
else
   L = links;
end
for ct=1:length(L)
   this.addlink(L(ct));
end
