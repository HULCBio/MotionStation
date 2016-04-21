function html = tic6000bhelp(fileStr)
% TIC6000BHELP       TIC6000 on-line help function.
%   Points Web browser to the HTML help file corresponding to this
%   TI C6000 block.  The current block is queried for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','web(tic6000bhelp);');

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:00:52 $

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
   % Rename file if part of DSP Library blocksets  
   if strcmp(get_param(gcb,'Parent'), 'tic62dsplib'),
       html_file = ['c62x' html_file];
   elseif strcmp(get_param(gcb,'Parent'), 'tic64dsplib'),
       html_file = ['c64x' html_file];
   end
   
   % Construct full path to help file.
   % Use 3 forward slashes for portability of HTML file paths:
   html = ['file:///' d '/toolbox/tic6000/' html_file];
end
return

% --------------------------------------------------------
function html_file = getarg_help_file(fileStr)

html_file = help_name(fileStr);
return


% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% Only masked blocks call tic6000bhelp, so if
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


% [EOF] tic6000bhelp.m
