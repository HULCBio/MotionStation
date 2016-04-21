function utCheckSystem(sys)
% Validity check for system meta data.

%   Author: P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:54 $
  
% RE: InputName and OutputName are assumed to reflect the true I/O size. 
[Ny,Nu] = iosize(sys);

% Check InputGroup 
try
   iGroups = getgroup(sys.InputGroup);
catch 
   iGroups = [];
end
if ~isa(iGroups,'struct') || ~isequal(size(iGroups),[1 1])
   error('Invalid value for InputGroup property.')
end
for f=fieldnames(iGroups).'
   channels = iGroups.(f{1});
   if ~isnumeric(channels) || ~isvector(channels) || ...
         isempty(channels) || size(channels,1)~=1 || ...
         ~isequal(channels,round(channels))
      error('InputGroup channels must be specified as row vectors of indices.')
   elseif any(channels<1) || any(channels>Nu),
      error('InputGroup channel indices are out of range.')
   elseif length(unique(channels))<length(channels)
      error('InputGroup channels cannot be repeated.')
   end
end

% Check OutputGroup 
try
   oGroups = getgroup(sys.OutputGroup);
catch 
   oGroups = [];
end
if ~isa(oGroups,'struct') || ~isequal(size(oGroups),[1 1])
   error('Invalid value for InputGroup property.')
end
for f=fieldnames(oGroups).'
   channels = oGroups.(f{1});
   if ~isnumeric(channels) || ~isvector(channels) || ...
         isempty(channels) || size(channels,1)~=1 || ...
         ~isequal(channels,round(channels))
      error('OutputGroup channels must be specified as row vectors of indices.')
   elseif any(channels<1) || any(channels>Ny),
      error('OutputGroup channel indices are out of range.')
   elseif length(unique(channels))<length(channels)
      error('OutputGroup channels cannot be repeated.')
   end
end