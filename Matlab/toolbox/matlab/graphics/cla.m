function ret_ax = cla(varargin)
%CLA Clear current axis.
%   CLA deletes all children of the current axes with visible handles.
%
%   CLA RESET deletes all objects (including ones with hidden handles)
%   and also resets all axes properties, except Position and Units, to
%   their default values.
%
%   CLA(AX) or CLA(AX,'RESET') clears the single axes with handle AX.
%
%   See also CLF, RESET, HOLD.

%   CLA(..., HSAVE) deletes all children except those specified in
%   HSAVE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17.4.1 $  $Date: 2002/10/24 02:10:54 $

if nargin>0 & length(varargin{1})==1 & ishandle(varargin{1}) & strcmp(lower(get(varargin{1},'Type')),'axes')
    % If first argument is a single axes handle, apply CLA to these axes
    ax = varargin{1};
    extra = varargin(2:end);
else
    % Default target is current axes
    ax = gca;
    extra = varargin;
end

clo(ax, extra{:});
    
if (nargout ~= 0)
    ret_ax = ax;
end
