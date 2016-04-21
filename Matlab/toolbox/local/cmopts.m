function out = cmopts(variableName)
%CMOPTS Version control settings.
%   CMOPTS returns the name of your version control system. To specify the
%   version control system, select Preferences from the File menu.
%
%   OUT=CMOPTS('VARIABLENAME') returns the setting for VARIABLENAME
%   as a string OUT.
%
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CUSTOMVERCTRL, CLEARCASE,
%   PVCS, SOURCESAFE, and RCS.

%   Author(s): Vaithilingam Senthil
%   Copyright 1984-2001 The MathWorks, Inc.
%   $Revision: 1.27.4.1 $  $Date: 2004/04/25 21:35:28 $

lerror = lasterr;
[lwarn, lwarnid] = lastwarn;
warnState = warning('off', 'all');
try
  import com.mathworks.services.Prefs;
  prefs = char(Prefs.getStringPref(Prefs.SOURCE_CONTROL_SYSTEM, 'None'));
catch
  prefs = 'None';
end
lasterr(lerror);
lastwarn(lwarn, lwarnid);
warning(warnState);

if nargin == 0
  out = prefs;
  return;
else
  try
	out = eval(variableName);
  catch
	error(['''' variableName '''' ' not defined.']);
  end
end
