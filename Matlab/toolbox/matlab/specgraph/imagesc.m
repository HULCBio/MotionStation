function h = imagesc(varargin)
%IMAGESC Scale data and display as image.
%   IMAGESC(...) is the same as IMAGE(...) except the data is scaled
%   to use the full colormap.
%   
%   IMAGESC(...,CLIM) where CLIM = [CLOW CHIGH] can specify the
%   scaling.
%
%   See also IMAGE, COLORBAR, IMREAD, IMWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.3 $  $Date: 2004/04/10 23:31:52 $

clim = [];
if nargin == 0,
  hh = image('CDataMapping','scaled');
elseif nargin == 1,
  hh = image(varargin{1},'CDataMapping','scaled');
elseif nargin > 1,

  % Determine if last input is clim
  if isequal(size(varargin{end}),[1 2])
    for i=length(varargin):-1:1,
      str(i) = isstr(varargin{i});
    end
    str = find(str);
    if isempty(str) | (rem(length(varargin)-min(str),2)==0), 
       clim = varargin{end};
       varargin(end) = []; % Remove last cell
    else
       clim = [];
    end
  else
     clim = [];
  end
  hh = image(varargin{:},'CDataMapping','scaled');
end

% Get the parent Axes of the image
cax = ancestor(hh,'axes');

if ~isempty(clim),
  set(cax,'CLim',clim)
elseif ~ishold(cax),
  set(cax,'CLimMode','auto')
end

if nargout > 0
    h = hh;
end
