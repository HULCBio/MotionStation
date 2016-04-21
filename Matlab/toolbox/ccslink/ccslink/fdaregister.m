function fdapluginstruct = fdaregister
%FDAREGISTER Registers the Code Composer Studio(tm) IDE plugin with FDATool.

%   Author(s): R. Losada
%   Copyright 2000-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2004/04/08 20:47:25 $ 

fdapluginstruct.plugin             =  {@exportccsplugin};
fdapluginstruct.name               =  {'MATLAB Link for Code Composer Studio(R)'};
fdapluginstruct.version            =  {1.0};

% Export to CCS is only available on a Windows PC
fdapluginstruct.supportedplatforms =  {'PCWIN'}; % Matches the output of COMPUTER

% [EOF]
