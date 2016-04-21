function Li = utInv(L)
% Metadata management for model inversion

%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:00 $
Li = L;

% Delete Notes and UserData
Li.Notes = {};
Li.UserData = [];
if ~isempty(L.Name)
   Li.Name = sprintf('inv(%s)',L.Name);
end

% Swap I/O names
Li.InputName = L.OutputName;
Li.OutputName = L.InputName;

% Swap I/O groups
Li.InputGroup = L.OutputGroup;
Li.OutputGroup = L.InputGroup;