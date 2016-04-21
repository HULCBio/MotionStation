function [style,color,marker,msg] = colstyle(a,plotout)
%COLSTYLE Parse color and style from string.
%   [L,C,M,MSG] = COLSTYLE('linespec') parses the line specification
%   'linespec' and returns the linetype part in L, the color part in C,
%   and the marker part in M.  L,C and M are empty arguments for
%   parts that are not specified or if there is a parsing error.  In
%   case of error, MSG will contain the error message string.

%   [L,C,M,MSG] = COLSTYLE(LINESPEC, 'plot') parses LINESPEC and
%   returns 'none' instead of empty if only one of linestyle or marker
%   are specified. This is to be compatible with the behavior of PLOT
%   which interprets, for example, '-' as marker 'none' and linestyle '-'.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/10 23:31:38 $

if nargin > 2 | (nargin ==1 & ~isstr(a))
    error('Requires one string argument.');
end

valid_colors = 'ymrgbwkc'; % and don't forget c followed by an integer
valid_lines = '-:'; % don't forget -- and -.
valid_markers = '+o*.xsdv^><ph';

style = ''; color = ''; marker = ''; msg = [];

if isempty(a), return, end

% Look for bad characters
[aa,b] = meshgrid(a,[valid_colors valid_lines valid_markers '0123456789']);
if any(all(aa~=b)), msg = 'Bad characters in LineSpec string.'; return, end

% Look for color
[aa,c] = meshgrid(a,valid_colors);
[kr,kc] = find(aa==c);
if ~isempty(kc), % found a color
  kc = min(kc);
  color = a(kc);
  if color == 'c' & kc<length(a), % Check for c followed by integer
    d = a(kc+1:end) >= '0' & a(kc+1:end) <= '9';
    d = find(d(1:min(length(d),2)));
    if ~isempty(d), color = [color a(d+kc)]; end
  end
end

% Look for style
[aa,l] = meshgrid(a,valid_lines);
[kr,kc] = find(aa==l);
if ~isempty(kc), % Found a line style
  kc = min(kc);
  style = a(kc);
  if style == '-' & kc<length(a), % Check for -. and --
    if a(kc+1)=='-',
      style = '--';
    elseif a(kc+1)=='.'
      style = '-.';
      a(kc+1)=' '; % Make sure '.' doesn't show up as a marker.
    end
  end
end

% Look for marker
[aa,m] = meshgrid(a,valid_markers);
[kr,kc] = find(aa==m);
if ~isempty(kc), % Found a line style
  kc = min(kc);
  marker = a(kc);
end

if length(style)+length(color)+length(marker) ~= length(a)
  msg = 'Invalid LineSpec string.';
end

if nargin == 2
  if isempty(style) && ~isempty(marker)
    style = 'none';
  end
  if ~isempty(style) && isempty(marker)
    marker = 'none';
  end
end