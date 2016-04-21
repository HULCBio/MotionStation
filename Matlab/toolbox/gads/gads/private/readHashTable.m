function options = readHashTable(h)
% Transfers data from the java gui to a gaoptions struct.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2004/01/16 16:50:04 $

% you will never call this yourself, only the GUI handling code will use
% it.

options = gaoptions;
options = getProperty(h,options,'FitnessFcn');

options = getProperty(h,options,'GenomeType',true);
options = getProperty(h,options,'GenomeLength');
%options = getProperty(h,options,'GenomeRange');

options = getProperty(h,options,'CreationFcn');
%options.CreationFcnArgs = {};

options = getProperty(h,options,'FitnessScalingFcn');
options = getProperty(h,options,'SelectionFcn');
options = getProperty(h,options,'CrossoverFcn');
options = getProperty(h,options,'MutationFcn');

options = getProperty(h,options,'HybridFcn');
%options.HybridFcn = @fminsearch;

% Display-----------------------------------
options = getProperty(h,options,'OutputFcns');
%options.DisplayFcnsArgs = {}; % used in runDisplayFcns at line 15.
options = getProperty(h,options,'OutputInterval');
% Survival---------------------------------------
options = getProperty(h,options,'PopulationSize');
options = getProperty(h,options,'EliteCount');

% Reproduction-------------------------------------------

options = getProperty(h,options,'CrossoverFraction');

%options = getProperty(h,options,'LargeMutationFraction');
%options = getProperty(h,options,'SmallMutationExponent');

% Migration--------------------------------------------

options = getProperty(h,options,'MigrationInterval');
options = getProperty(h,options,'MigrationFraction');
options = getProperty(h,options,'MigrationDirection',true);

% Stopping Criteria------------------------------------------

options = getProperty(h,options,'Generations');
options = getProperty(h,options,'TimeLimit');
options = getProperty(h,options,'FitnessLimit');
options = getProperty(h,options,'StallGenLimit');
options = getProperty(h,options,'StallTimeLimit');

% keys = h.keys;
% while(keys.hasNext)
%     key = keys.next;
%     value = h.get(key);
%     fprintf(1,'Unused property: %s = %s\n',key,value)
% end

function options = getProperty(h,options,name,stringify)

if(nargin < 4)
    stringify = false;
end

v = h.get(name);

%fprintf(1,'reading %s as %s\n',name,v);

if(isempty(v))
     fprintf(1,'Found no entry for %s\n',name);
     return;
end
   
if(~stringify)
    v = eval(v);
end

if(~isempty(v))
    %fprintf(1,'Setting %s to %s\n',name,value2RHS(v));
    options.(name) = v;
else
    fprintf(1,'Found %s to be empty\n',name);
end
%h.remove(name);


