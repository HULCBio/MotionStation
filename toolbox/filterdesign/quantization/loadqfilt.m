function varargout = loadqfilt(varargin)
%LOADQFILT   Load the MAT file and convert all QFILTs to DFILTs.
%   LOADQFILT FILENAME loads all variables from the MAT file FILENAME.  If
%   any QFILT objects are found, they are converted to DFILT objects.
%
%   When settings of the loaded QFILTs cannot be mapped to DFILTs settings,
%   warnings will be produced.  If the warning state is set to 'off' these
%   will be suppressed.
%
%   For additional input options see LOAD.

%   Author(s): J. Schickler
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 22:51:14 $

% Load the specified file.
s = ploadqfilt(varargin{:});

if nargout
    varargout = {s};
else
    
    w = fieldnames(s);

    for indx = 1:length(w)
        assignin('caller', w{indx}, s.(w{indx}));
    end
end

% [EOF]
