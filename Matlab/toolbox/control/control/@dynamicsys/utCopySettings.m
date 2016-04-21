function sys = utCopySettings(sys,refsys)
% Copies @dynamicsys settings from reference model.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:56 $
sys.InputName = refsys.InputName;
sys.OutputName = refsys.OutputName;
sys.InputGroup = refsys.InputGroup;
sys.OutputGroup = refsys.OutputGroup;
sys.Name = refsys.Name;
sys.Notes = refsys.Notes;
sys.UserData = refsys.UserData;