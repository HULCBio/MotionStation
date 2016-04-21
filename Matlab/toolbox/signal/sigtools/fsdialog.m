function varargout = fsdialog(varargin)
%FSDIALOG Create a Sampling Frequency Dialog
%   hFs = FSDIALOG Create a dialog in which a user can specify a sampling
%   frequency.  This function will return an object which will contain the 
%   Sampling Frequency information.
%
%   FSDIALOG(DFs) Create a dialog in which a user can specify a sampling
%   frequency.  DFs will be used as the default.
%
%   See also FDATOOL, FVTOOL, WINTOOL.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:51:26 $

% Instantiate the FsDialog object
hFs = siggui.fsdialog(varargin{:});

% Render the dialog
render(hFs);
set(hFs, 'Visible', 'On');

if nargout
    varargout{1} = hFs;
end

% [EOF]
