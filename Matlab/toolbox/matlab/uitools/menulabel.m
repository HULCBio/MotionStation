function [label, acc] = menulabel(inlabel)
%MENULABEL Parse menu label for keyboard equivalent and accelerator keys.
%   Note: This function is OBSOLETE.  In MATLAB 5, 
%   uimenu label strings work the same on all platforms.
%
%   [LABEL, ACC] = MENULABEL(INLABEL) parses the string INLABEL
%   to determine the appropriate label-setting string to use in
%   a uimenu call.  In the INLABEL string, use a & before a letter
%   to make that letter the keyboard equivalent.  If you
%   really want an '&' in your menu label, put '\&' in INLABEL.
%   Use a '^q' at the end of the string to make 'q' an
%   accelerator key.

%   Steven L. Eddins, 27 May 1994
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/15 03:25:23 $


% Replace \& by &&.

loc = findstr(inlabel, '\&');
amp = '&';
inlabel(loc) = amp(1,ones(1,length(loc)));

% Find the accelerator key, if any.
L = length(inlabel);
if (L > 1)
  if (inlabel(L-1) == '^')
    acc = inlabel(L);
    inlabel(L-1:L) = [];
  else
    acc = char([]);
  end
else
  acc = char([]);
end

label = inlabel;
