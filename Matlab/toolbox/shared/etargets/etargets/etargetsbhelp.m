function html = etargetsbhelp(fileStr)
% ETARGETSBHELP on-line help gateway function for 
%   ETARGETS shared components.
%   Points Web browser to the HTML help file corresponding to this
%   block.  The current block is queried for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','web(etargetsbhelp);');

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/04/01 16:17:37 $

error(nargchk(0,1,nargin));
d = docroot;

if isempty(d),
    % Help system not present:
    html = ['file:///' matlabroot '/toolbox/local/helperr.html'];
else
    %%%%%%%  R14FCS Implementation   %%%%%%%%%
    m = get_param(gcb, 'MaskType');
    isFromMem = ~isempty(findstr(m, 'From Memory'));
    isToMem = ~isempty(findstr(m, 'To Memory'));
    if  isFromMem || isToMem,
        if isFromMem,
            fname = 'frommemory.html';
        else
            fname = 'tomemory.html';
        end
        if exist('c2000lib'),
            % C2000 product is installed; must use its doc.
            html = ['file:///' d '/toolbox/tic2000/' fname];
        else
            % Only C6000 product is installed
            html = ['file:///' d '/toolbox/tic6000/' fname];
        end
    end
    % Do nothing if this file is called for a block other than 
    % From & To Memory.  We don't have a strategy for
    % this yet.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% old implementation (to be updated)  %%%%%%%
    %         if nargin < 1
    %             % Derive help file name from mask type:
    %             html_file = getblock_help_file(gcb);
    %         else
    %             % Derive help file name from fileStr argument:
    %             html_file = getarg_help_file(fileStr);
    %         end
    %
    %         % Construct full path to help file.
    %         % Use 3 forward slashes for portability of HTML file paths:
    %         html = ['file:///' d '/toolbox/tic2000/' html_file];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
return

% --------------------------------------------------------
function html_file = getarg_help_file(fileStr)

html_file = help_name(fileStr);
return


% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% Only masked blocks call c2000help, so if
% we get here, we know we can get the MaskType string.
fileStr = get_param(blk,'MaskType');
help_file = help_name(fileStr);

return

% ---------------------------------------------------------
function y = help_name(x)
% Returns proper help-file name
%
% Invoke same naming convention as used with the
% auto-generated help conversions for the blockset
% on-line manuals.
%
% - only allow a-z, 0-9, underscore, and period

if isempty(x), x='default'; end
y = lower(x);
y(find(~isvalidchar(y))) = '';  % Remove invalid characters
y = [y '.html'];

return


% ---------------------------------------------------------
function y = isvalidchar(x)
y = isletter(x) | isdigit(x) | isunder(x) | isdot(x);
return


% ---------------------------------------------------------
function y = isdigit(x)
y = (x>='0' & x<='9');
return


% ---------------------------------------------------------
function y = isunder(x)
y = (x=='_');
return

% ---------------------------------------------------------
function y = isdot(x)
y = (x=='.');
return

% [EOF]
