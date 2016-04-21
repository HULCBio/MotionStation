function html = cdmaweb(blkname)
%CDMAWEB CDMA Reference Blockset online help function.
%   Points Web browser to the HTML help file corresponding to this
%   CDMA Reference Blockset block.  The current block is queried 
%   for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','web(cdmaweb);');

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 16:35:49 $

error(nargchk(0,1,nargin));
d = docroot;

if nargin==0,
   % Only masked CDMA Blocks call cdmaweb, so if
   % we get here, we know we can get the MaskType string.
   blkname = get_param(gcb,'MaskType');
end

% Construct full path to help file.
% Use 3 forward slashes for portability of HTML file paths:
html = ['file:///' d '/toolbox/cdma/' help_name(blkname)];
return

% ---------------------------------------------------------
function y = help_name(x)
% Returns proper help-file name
% - only allow a-z, 0-9, and underscore
% - truncate to 25 chars max, plus ".html"

if isempty(x), x='default'; end
y = lower(x);
y(find(~isvalidchar(y))) = '';  % Remove invalid characters
if length(y)>25, y=y(1:25); end
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

% [EOF] cdmaweb.m
