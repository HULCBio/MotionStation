function setScalar(this,DSLink,GridSize)
%SETSCALAR  Scalar assignment into link array.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:44 $

% Extract linked data set
if ~isa(DSLink,'cell') || ~isa(DSLink{1},'hds.AbstractDataSet')
   error('Invalid value for data link %s. Expects cell array of data set handles.',this.Alias.Name)
end
DS = DSLink{1};

% Update template and list of linked variables
[vars,dependvars] = getvars(DS);
this.Template = DS;
this.LinkedVariables = [vars;dependvars];

% Populate link array
Links = cell(GridSize);
for ct=1:prod(GridSize)
   % Clone data set
   if ct==1
      Links{ct} = DS;
   else
      % RE: Also copies data
      Links{ct} = copy(DS);
   end
end
this.Links = Links;
