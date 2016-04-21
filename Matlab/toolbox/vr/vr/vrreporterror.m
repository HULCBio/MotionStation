function vrreporterror
% VRREPORTERROR Report a VR Toolbox error.
%   VRREPORTERROR reports a VR Toolbox error based on VrInterfaceException
%   message coming from Java interface.
%
%   Not to be called directly.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/02/11 14:20:58 $ $Author: Xjhouska $


% find the VrInterfaceException marker - report unexpected error if not found
err = lasterr;
pos = findstr(err, 'VrInterfaceException:');
if isempty(pos)
  error('VR:unexpected', '%s', err);
end;

% find the # identifier delimiters - report unexpected error if not found
err = err(pos:end);
pos = find(err=='#');
if length(pos)<2
  error('VR:unexpected', '%s', err);
end;

% report the error, using parsed identifier and message text
eol = min([find(err==char(10)) find(err==char(13)) length(err)+1]);
error(['VR:' err((pos(1)+1):(pos(2)-1))], '%s', err((pos(2)+1):(eol-1)));
