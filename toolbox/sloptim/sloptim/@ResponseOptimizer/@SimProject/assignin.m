function assignin(this,Params)
% Assigns parameter values in appropriate workspace.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:06 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Discard parameters that are not tuned (efficiency + 
% avoids failures when p1 = p2(1), p1 is tuned, but
% p2 is not)
Params = find(Params,'-function','Tuned',@(x) any(x(:)));

% Collect parameter data in structure
pnames = get(Params,{'Name'});
ps = struct('Name',pnames,'Value',get(Params,{'Value'}),...
   'Workspace',utFindParams(this.Model,pnames));

% Perform assignment
utAssignParams(this.Model,ps)