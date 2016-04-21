function x = vrview(filename, option)
%VRVIEW View virtual worlds.
%   VRVIEW shows a page with a list of all virtual worlds
%   currently available for viewing. It always uses the Web browser.
%
%   X = VRVIEW(FILENAME) creates a virtual world based on FILENAME, then
%   opens it if it is not yet open and finally views it as if VIEW was issued.
%   The VRWORLD handle to the world is returned.
%
%   X = VRVIEW(FILENAME, '-internal') and X = VRVIEW(FILENAME, '-web') forces
%   use of internal or Web browser, respectively.
%
%   See also VRWORLD, VRWORLD/OPEN, VRWORLD/VIEW.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.10.4.2 $ $Date: 2003/10/09 04:37:32 $ $Author: batserve $


% no arguments supplied - open the main page
if nargin==0

  % read the HTTP port
  p = vrgetpref('HttpPort');

  % open the Web browser
  s = web(sprintf('http://127.0.0.1:%d', p), '-browser');
  if s==1
    error('VR:browsererror', 'Web browser not found.');
  elseif s==2
    error('VR:browsererror', 'Error invoking Web browser.');
  end

  return;
end

% open the world specified by filename

x = vrworld(filename);
if ~isopen(x)
  open(x);
end
if nargin>1
  view(x, option);
else
  view(x);
end
