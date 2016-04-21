function html = ccsblkshelp(fileStr)
%  On-line help function for Simulink blocks in ccsblks
%   Points Web browser to the HTML help file corresponding to current
%   block.
%   The current block is queried for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','web(ccsblkshelp);');

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:37 $

error(nargchk(0,1,nargin));
d = docroot;

if isempty(d),
   % Help system not present:
   html = ['file:///' matlabroot '/toolbox/local/helperr.html'];
else
   if nargin < 1
      % Derive help file name from mask type:
      html_file = getblock_help_file(gcb);
   else
      % Derive help file name from fileStr argument:
      html_file = getarg_help_file(fileStr);
   end
   
   % Construct full path to help file.
   % Use 3 forward slashes for portability of HTML file paths:
   html = ['file:///' d '/toolbox/ccslink/' html_file];
end

% --------------------------------------------------------
function html_file = getarg_help_file(fileStr)

html_file = help_name(fileStr);


% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% Only masked blocks call this file, so if
% we get here, we know we can get the MaskType string.
fileStr = get_param(blk,'MaskType');
help_file = help_name(fileStr);


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



% ---------------------------------------------------------
function y = isvalidchar(x)
y = isletter(x) | isdigit(x) | isunder(x) | isdot(x);


% ---------------------------------------------------------
function y = isdigit(x)
y = (x>='0' & x<='9');


% ---------------------------------------------------------
function y = isunder(x)
y = (x=='_');

% ---------------------------------------------------------
function y = isdot(x)
y = (x=='.');


% [EOF] 
