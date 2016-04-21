function boolflag = sigisappdata(h, varargin)
%SIGISAPPDATA Returns true if the application data exists
%   SIGISAPPDATA(H, NAME) returns 1 if application-defined data with
%   the specified NAME exists on the object specified by handle H,
%   and returns 0 otherwise.
%
%   SIGISAPPDATA(H, NAME, SUBNAME1, SUBNAME2, etc) returns 1 if
%   application-defined data with specified SUBNAMEs exists.
%
%   See also SIGSETAPPDATA, SIGGETAPPDATA, SIGRMAPPDATA.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/28 19:27:06 $

error(nargchk(2,inf,nargin));

% Check the starting position
start    = varargin{1};
boolflag = isappdata(h, start);

if length(varargin) > 1,
    path = varargin(2:end);
    data = getappdata(h, start);
    
    % Loop over the path until you find a field that doesn't exist
    indx = 1;
    while boolflag & indx <= length(path)
        boolflag = isfield(data, path{indx});
        if boolflag,
            data = data.(path{indx});
        end
        indx = indx + 1;
    end
end

% [EOF]
