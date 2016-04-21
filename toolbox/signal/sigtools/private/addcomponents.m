function addcomponents(hFDA)
%ADDCOMPONENTS Add components to FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/11/21 15:35:15 $ 

% Install the Sidebar Object
fdatool_sidebar(hFDA);

status(hFDA, 'Initializing Filter Design and Analysis Tool ....');

% Install the Current Filter Information Object
fdatool_cfi(hFDA);

% Install the FVTool
fdatool_fvtool(hFDA);

% [EOF]
