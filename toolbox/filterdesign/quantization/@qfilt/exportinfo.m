function s = exportinfo(Hq)
%EXPORTINFO Export information.

%   This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:25:07 $

error(nargchk(1,1,nargin));

% Both coefficientnames & coefficientvariables return cell arrays.
s.variablelabel = coefficientnames(Hq);  
s.variablename = coefficientvariables(Hq);

% QFILTs can be exported as both objects and arrays.
s.exportas.tags = {'Coefficients','Objects'};

% QFILTs object specific labels and names
s.exportas.objectvariablelabel = qfiltname(Hq);
s.exportas.objectvariablename  = qfiltvariable(Hq);

% Optional fields (destinations & constructors) if exporting to destinations other 
% than the 'Workspace','Text-file', or, 'MAT-file';
s.destinations = {'Workspace','Coefficient File (ASCII)','MAT-file','SPTool'};
s.constructors = {'','sigio.xp2coeffile','','sigio.xp2sptool'};

% [EOF]
