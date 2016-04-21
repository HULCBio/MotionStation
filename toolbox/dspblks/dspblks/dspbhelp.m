function html = dspbhelp(fileStr)
% DSPBHELP Signal Processing Blockset on-line help function.
%   Points Web browser to the HTML help file corresponding 
%   to this Signal Processing Blockset block.  The current 
%   block is queried for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','web(dspbhelp);');

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.22.4.2 $ $Date: 2004/04/12 23:05:13 $

error(nargchk(0,1,nargin));
d = docroot;

if isempty(d),
   % Help system not present:
   html = ['file:///' matlabroot '/toolbox/dspblks/dspblks/dspbherr.html'];
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
   html = ['file:///' d '/toolbox/dspblks/' html_file];
end
return

% --------------------------------------------------------
function html_file = getarg_help_file(fileStr)

html_file = help_name(fileStr);
return


% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% Version 4.0 libraries:
s = dspliblist;
libsv4 = s.dsp4;

refBlock = get_param(blk,'ReferenceBlock'); 
if ~isempty(refBlock) 
   sys = strtok(refBlock, '/');
else 
   sys = get_param(blk,'Parent'); 
end 

if isempty(strmatch(sys,libsv4,'exact'))
   % Not a version 4 block, no online help is available.
   fileStr = 'olddspblocksethelp';
   
else
   % Version 4 block, online help is available:
   
   % Only masked Signal Processing Blockset blocks call 
   % dspbhelp, so if we get here, we know we can get the 
   % MaskType string.
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
% on-line manuals.
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


% [EOF] dspbhelp.m
