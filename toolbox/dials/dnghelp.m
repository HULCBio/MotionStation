function dnghelp
%DNGHELP Display help for Dials & Gauges Blockset.
%   Displays help page in the MATLAB Help browser, based on
%   the MaskType property of the current block.
%
%   Author(s): P. Barnard, K. Kohrt
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $ $Date: 2003/12/15 15:53:20 $

d = docroot;

if isempty(d),
   % No doc directory.
   error(['Help system is unavailable.  Try using the ',...
      'Web-based documentation set at http://www.mathworks.com']);
else
   % Look for help page.
   % First find the MaskType property of the current block.
   fileStr = get_param(gcb,'MaskType');
   fileStr = strrep(lower(fileStr),' ',''); % Make lowercase and remove spaces.

   % Use dials.map file to find the corresponding HTML page for the block.
   html_file=fullfile(d,'toolbox','dials','dials.map');
   html_file=strrep(html_file,'\','/'); % To be safe, replace any backslashes.

   helpview(html_file,fileStr); % Display the help page.
end

return
