function root = slroot
%SLROOT Returns the Simulink Root object.
%   root = SLROOT

%   Sanjai Singh
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $

persistent ROOT;
mlock

% Get a reference to the Root object.
if isempty(ROOT)
  ROOT = Simulink.Root;
end

root = ROOT;
