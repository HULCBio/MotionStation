function varargout = parameterdlg(varargin)
%PARAMETERDLG Create a parameter dialog box

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:52:55 $

error(nargchk(1,3,nargin));

hPD = siggui.parameterdlg(varargin{:});
render(hPD);
set(hPD, 'Visible', 'On');

if nargout,
    varargout{1} = hPD;
end

% [EOF]
