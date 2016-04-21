function lnkfvtool2mask(hBlk)
%LNKFVTOOL2MASK Callback for linking FVTool to a block mask.
%   LINKEDFVTOOL_CB(HBLK) will launch a new FVTool or re-use an existing
%   FVTool from a block mask. The handle to FVTool will be stored in the
%   UserData of the block in a field of a structure called 'fvtool', e.g.,
%   ud.fvtool.
%   
%   In order to enable the launching of FVTool, you must do the following:
%
%   1. Store a filter object in the block's UserData in a structure whose
%   field is: 'filter', e.g., ud.filter
%   
%   2. Requires that an 'On'/'Off' parameter be defined in the block mask with a
%   variable name of 'launchFVT'.
%
%   3. This function must be defined as the 'callback' for the 'launchFVT'
%   parameter from the Mask Editor.
%   
%   4. This function must be called from the 'init' portion of the mask
%   helper function so that FVTool will be updated based on changes to the
%   filter parameters.
%
%   See also FVTOOLWADDNREPLACE.

%   Author(s): J. Schickler, P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:32:02 $

error(nargchk(0,1,nargin));
if nargin < 1, hBlk = gcbh;; end

ud = get_param(hBlk, 'UserData');

% Because Simulink will always evaluate the function (since it's defined as
% a callback), return when there is no filter stored in the UserData.
if ~isfield(ud,'filter'),
   return;
end
filtobj = ud.filter;


if strcmpi(get_param(hBlk, 'launchFVT'), 'off')
    if isempty(ud) | ~isfield(ud, 'fvtool') | ~isa(ud.fvtool, 'sigtools.fvtool')
        ud.fvtool = [];
    else
        set(ud.fvtool, 'Visible', 'Off');
    end
else
    if isempty(ud) | ~isfield(ud, 'fvtool') | ~isa(ud.fvtool, 'sigtools.fvtool'),
        ud.fvtool = fvtoolwaddnreplace(filtobj);
    else
        if strcmpi(get(ud.fvtool, 'LinkMode'), 'replace'),
            ud.fvtool.setfilter(filtobj);
        else
            ud.fvtool.addfilter(filtobj);
        end
    end
    set(ud.fvtool, 'Visible', 'On');
end

set_param(hBlk, 'UserData', ud);

% [EOF]
