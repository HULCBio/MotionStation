function sys = loadobj(s)
%LOADOBJ  Load filter for LTI objects.

%   Author(s): G. Wolodkin, P. Gahinet, 4-17-98
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/02/06 00:22:10 $

if isa(s,'lti') && s.Version==getVersion(s)
   % Object is current
   sys = s;
   return
end

% Create LTI object of the same size
ny = length(s.OutputName);
nu = length(s.InputName);
sys = lti(ny,nu,s.Ts);
sys.Version = s.Version;  % needed to pass version to subclasses' LOADOBJ

% Flags to determine if repeated i/o channels and names are modified during
% load
GInputChannelsModified = false;
GInputNamesModified = false;
GOutputChannelsModified = false;
GOutputNamesModified = false;
 
switch s.Version
case 1
   % Copy properties specific to Version 1 object S to SYS
   if any(s.Td)
      sys.InputDelay = s.Td';
   end
   
case 2
   % Copy properties specific to Version 2 object S to SYS
   sys.ioDelay      = s.ioDelayMatrix;
   sys.InputDelay   = s.InputDelay;
   sys.OutputDelay  = s.OutputDelay;
   [sys.InputGroup, GInputChannelsModified, GInputNamesModified]  = LocalGroupUpdate(s.InputGroup);
   [sys.OutputGroup, GOutputChannelsModified, GOutputNamesModified]  = LocalGroupUpdate(s.OutputGroup);
   
case 3
   % Copy properties specific to Version 3 object S to SYS
   sys.ioDelay      = s.ioDelay;
   sys.InputDelay   = s.InputDelay;
   sys.OutputDelay  = s.OutputDelay;
   [sys.InputGroup, GInputChannelsModified, GInputNamesModified]   = LocalGroupUpdate(s.InputGroup);
   [sys.OutputGroup, GOutputChannelsModified, GOutputNamesModified]  = LocalGroupUpdate(s.OutputGroup);
   
end

% Copy non-specific properties
sys.InputName    = s.InputName;
sys.OutputName   = s.OutputName;
sys.Notes        = s.Notes;
sys.UserData     = s.UserData;


% Display warnings if groups names or channels have been modified
if GInputChannelsModified || GOutputChannelsModified
    warning('control:LTIUpdate','Repeated channels in the input/output groups have been removed.');
end
if GInputNamesModified || GOutputNamesModified
    warning('control:LTIUpdate','Blanks in the input/output group names have been replaced with an underscore (''_'').')
end



%----------------------- Local Functions ---------------------------------

function [g, GChannelsModified, GNamesModified]  = LocalGroupUpdate(g)
% Update groups to account for new restrictions with struct-based groups

% Boolean variables to determine if repeated i/o channels and names are
% modified during update
GChannelsModified = false;
GNamesModified  = false;

ng = size(g,1);
if ng==0
   % Migrate to struct when no group specified
   g = struct;
   return
elseif size(g,2)==1
   g(:,2) = {''};
end

% Remove multiplicity of group channels and spaces in group name
for cnt = 1:ng
    gcurrent = g{cnt,1};
    [gunique, gidx] = unique(gcurrent);
    if length(gunique) < length(gcurrent)
        gnew = gcurrent(sort(gidx));
        g{cnt,1} = gnew;
        GChannelsModified = true;
    end
    if ~isempty(findstr(g{cnt,2},' '))
        g{cnt,2} = regexprep(g{cnt,2},' ','_');
        GNamesModified  = true;
    end
end
    
idxNoName = find(cellfun('length',g(:,2))==0);
if ~isempty(idxNoName)
   % Clear names starting with group
   g(:,strncmp(g(:,2),'Group',5)) = {''};
   idxNoName = find(cellfun('length',g(:,2))==0);
end
for ct=1:length(idxNoName)
   g{idxNoName(ct),2} = sprintf('Group%d',ct);
end
