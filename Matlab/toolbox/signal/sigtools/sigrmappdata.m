function sigrmappdata(h, varargin)
%SIGRMAPPDATA Remove the application data with multiple fields
%   SIGRMAPPDATA(H, NAME) removes the application-defined data NAME,
%   from the object specified by handle H.
%
%   SIGRMAPPDATA(H, NAME, SUBNAME1, SUBNAME2, etc) removes the
%   application-defined data using SUBNAME1, SUBNAME2, etc.
%
%   See also SIGSETAPPDATA, SIGGETAPPDATA, SIGISAPPDATA.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:27:07 $

error(nargchk(2,inf,nargin));

if sigisappdata(h, varargin{:}),
    
    if length(varargin) == 1,
        rmappdata(h, varargin{1});
    else
        appdata = siggetappdata(h, varargin{1:end-1});
        appdata = rmfield(appdata, varargin{end});
        
        sigsetappdata(h, varargin{1:end-1}, appdata);
    end
end

% [EOF]
