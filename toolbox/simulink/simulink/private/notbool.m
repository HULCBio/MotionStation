function notval = notbool(val)
%NOTBOOL Utility function for toggling boolean strings.
%   NOTBOOL retunrs the logical opposite for the strings yes/no, on/off, as well
%   as the logical opposite for the values 1 and 0.
 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

if (isstr(val)),

  if (strcmp(val,'yes')),
    notval = 'no'; return;
  end

  if (strcmp(val,'no')),
    notval = 'yes'; return;
  end

  if (strcmp(val,'on')),
    notval = 'off'; return;
  end

  if (strcmp(val,'off')),
    notval = 'on'; return;
  end

else,

  notval = ~val;

end
