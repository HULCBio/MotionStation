function hh = title(varargin)
%TITLE  Graph title.
%   TITLE('text') adds text at the top of the current axis.
%
%   TITLE('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the title.
%
%   TITLE(AX,...) adds the title to the specified axes.
%
%   H = TITLE(...) returns the handle to the text object used as the title.
%
%   See also XLABEL, YLABEL, ZLABEL, TEXT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.6.5 $  $Date: 2004/04/10 23:26:37 $


error(nargchk(1,inf,nargin));

[ax,args,nargs] = axescheck(varargin{:});
if isempty(ax)
  % call title recursively or call method of Axes subclass
  h = title(gca,varargin{:}); 
  if nargout > 0, hh = h; end
  return;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error('Incorrect number of input arguments')
end

string = args{1};
pvpairs = args(2:end);

%---Check for bypass option
if isappdata(ax,'MWBYPASS_title')       
   h = mwbypass(ax,'MWBYPASS_title',string,pvpairs{:});

%---Standard behavior      
else
   h = get(ax,'title');

   %Over-ride text objects default font attributes with
   %the Axes' default font attributes.
   set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
          'FontName',   get(ax, 'FontName'), ...
          'FontSize',   get(ax, 'FontSize'), ...
          'FontWeight', get(ax, 'FontWeight'), ...
          'Rotation',   0, ...
          'string',     string, pvpairs{:});
end

if nargout > 0
  hh = h;
end
