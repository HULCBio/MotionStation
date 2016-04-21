function htmlOut = code2html(codeIn)
%CODE2HTML  Prepare MATLAB code for display in HTML
%   htmlOut = CODE2HTML(codeIn)
%   makes the following replacements for display purposes
%      <     &lt;
%      >     &gt;
%      &     &amp;

% Copyright 1984-2003 The MathWorks, Inc.

htmlPartial = codeIn;
% It's important that the ampersand run first in this list, otherwise the
% subsequent substitutions (which contain ampersands) will break.
htmlPartial = strrep(htmlPartial,'&','&amp;');
htmlPartial = strrep(htmlPartial,'<','&lt;');
htmlPartial = strrep(htmlPartial,'>','&gt;');
htmlOut = htmlPartial;