function preferences(varargin)
%PREFERENCES Bring up MATLAB user settable preferences dialog.

%   $Revision: 1.1.6.2 $ 
%   Copyright 1984-2003 The MathWorks, Inc.
if (nargin == 1)
    com.mathworks.mlservices.MLPrefsDialogServices.showPrefsDialog(varargin{1});
else
    com.mathworks.mlservices.MLPrefsDialogServices.showPrefsDialog;
end
