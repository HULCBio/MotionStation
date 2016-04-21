function html = commbhelp(fileStr)
% COMMBHELP  Get URL for Communications Blockset online help.
%
%   COMMBHELP returns the URL of the HTML help file corresponding to
%   the current Communications Blockset block.  To do this, the function
%   queries the current block for its MaskType.
%
%   COMMBHELP(fname) returns the URL for online help when the
%   string fname is a filename without the .html
%   extension. 
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','helpview(commbhelp);');

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:01:58 $

error(nargchk(0,1,nargin));
d = docroot;

if nargin < 1
  % Derive help file name from mask type:
  html_file = getblock_help_file(gcb);
else
  % Derive help file name from fileStr argument:
  html_file = help_name(fileStr);
end
html = fullfile(d,'toolbox','commblks','ref',html_file);
html=strrep(html,'\','/'); % To be safe, replace any backslashes
   
if isempty(d),
   error(['Help system is unavailable.  Try using the ',...
           'Web-based documentation set at http://www.mathworks.com']);
end
return

% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% Version 3.0 libraries:
s = commliblist;
libsvcur = s.comm3;

linkStatus = lower(get_param(blk,'LinkStatus'));

switch linkStatus
case 'resolved'
   rblock = get_param(blk,'ReferenceBlock');
   sys = get_param(rblock,'Parent');
case 'none'
   sys = get_param(blk,'Parent');
otherwise
   error('Unknown link status reported.');
end

if isempty(strmatch(sys,libsvcur,'exact'))
   % Version 1.x block, no online help available anymore:
   fileStr = 'commbhelp_old';
   
else
   % Version 2 block, online help available:
   
   % Only masked Communications Blockset blocks call commbhelp, so if
   % we get here, we know we can get the MaskType string.
   fileStr = get_param(blk,'MaskType');
end

help_file = help_name(fileStr);

return

% ---------------------------------------------------------
function y = help_name(x)
% Returns proper help-file name
%
% Invoke same naming convention as used with the
% auto-generated help conversions for the blockset
% online manuals.
%
% - only allow a-z, 0-9, and underscore
% - truncate to 25 chars max, plus ".html"

if isempty(x), x='default'; end
y = lower(x);
y(find(~isvalidchar(y))) = '';  % Remove invalid characters
y = [y '.html'];

return


% ---------------------------------------------------------
function y = isvalidchar(x)
y = isletter(x) | isdigit(x) | isunder(x);
return


% ---------------------------------------------------------
function y = isdigit(x)
y = (x>='0' & x<='9');
return


% ---------------------------------------------------------
function y = isunder(x)
y = (x=='_');
return


% [EOF] commbhelp.m
