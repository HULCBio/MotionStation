function hh = xlabel(varargin)
%XLABEL X-axis label.
%   XLABEL('text') adds text beside the X-axis on the current axis.
%
%   XLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the xlabel.
%
%   XLABEL(AX,...) adds the xlabel to the specified axes.
%
%   H = XLABEL(...) returns the handle to the text object used as the label.
%
%   See also YLABEL, ZLABEL, TITLE, TEXT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.6.5 $  $Date: 2004/04/10 23:26:38 $

error(nargchk(1,inf,nargin));

[ax,args,nargs] = axescheck(varargin{:});
if isempty(ax)
  % call xlabel recursively or call method of Axes subclass
  h = xlabel(gca,varargin{:}); 
  if nargout > 0, hh = h; end
  return;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error('Incorrect number of input arguments')
end

string = args{1};
pvpairs = args(2:end);

if isappdata(ax,'MWBYPASS_xlabel')
  h = mwbypass(ax,'MWBYPASS_xlabel',string,pvpairs{:});

  %---Standard behavior
else
  h = get(ax,'xlabel');

  %Over-ride text objects default font attributes with
  %the Axes' default font attributes.
  set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
         'FontName',   get(ax, 'FontName'), ...
         'FontSize',   get(ax, 'FontSize'), ...
         'FontWeight', get(ax, 'FontWeight'), ...
         'string',     string,pvpairs{:});
end

if nargout > 0
  hh = h;
end
