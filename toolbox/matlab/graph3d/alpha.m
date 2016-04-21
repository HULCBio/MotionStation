function alpha(param1, param2)
%ALPHA - Get or set alpha properties for objects in the current Axis
%
% ALPHA(VALUE)    - On all children of GCA, set an alpha property to VALUE.
% ALPHA(OBJECT, VALUE) - Set the alpha on OBJECT to VALUE
%
% Use a single alpha value for the object
%
% ALPHA(scalar)   - Set the face alpha to be the value of scalar
% ALPHA('flat')   - Set the face alpha to be flat.
% ALPHA('interp') - Set the face alpha to be interp. (if applicable.)   
% ALPHA('texture')- Set the face alpha to be texture. (if applicable.)   
% ALPHA('opaque') - Set the face alpha to be 1.
% ALPHA('clear')  - Set the face alpha to be 0.
%
% Specify an alpha value for each element in the object's data.
%
% ALPHA(MATRIX)   - Set the alphadata to be MATRIX.
% ALPHA('x')      - Set the alphadata to be the same as the x data.
% ALPHA('y')      - Set the alphadata to be the same as the y data.
% ALPHA('z')      - Set the alphadata to be the same as the z data.
% ALPHA('color')  - Set the alphadata to be the same as the color data.
% ALPHA('rand')   - Set the alphadata to be random values.
%
% ALPHA('scaled') - Set the alphadatamapping to scaled.
% ALPHA('direct') - Set the alphadatamapping to direct.
% ALPHA('none')   - Set the alphadatamapping to none.
%
% See also ALIM, ALPHAMAP
% Type "doc alpha" for more detailed information.

% To be done later?
%
% ALPHA('xnormal')- Set the alphadata to be the X part of the normals.
% ALPHA('ynormal')- Set the alphadata to be the Y part of the normals.
% ALPHA('znormal')- Set the alphadata to be the Z part of the normals.

% $Revision: 1.8 $ $Date: 2002/04/15 04:27:21 $
% Copyright 1984-2002 The MathWorks, Inc.

if nargchk(1, 2, nargin);
  error(nargchk(1, 2, nargin));
end

if nargin == 2 & ...
  sum(ishandle(param1)) == length(param1) & sum(param1 ~= 0) == length(param1)
  obj = param1;
  param1 = param2;
else
  obj = [ findobj(gca, 'type','surface'); 
	  findobj(gca, 'type','patch'); 
	  findobj(gca, 'type','image') ];
end

for j = 1:length(obj)

  proptype = 'none';
  
  if isa(param1, 'double')
    data = param1;
    if sum(size(param1) == 1) == 2
      proptype = 'FaceAlpha';
    else
      proptype = 'AlphaData';
    end
  else
    switch param1
     case 'opaque'
      data=1;
      proptype = 'FaceAlpha';
     case 'clear'
      data=0;
      proptype = 'FaceAlpha';
     case 'flat'
      data='flat';
      proptype = 'FaceAlpha';
     case 'interp';
      data='interp';
      proptype = 'FaceAlpha';
     case 'texture'
      data='texture';
      proptype = 'FaceAlpha';
     case 'z'
      proptype = 'AlphaData';
      switch get(obj(j), 'type')
       case 'surface'
	data = get(obj(j),'zdata');
       case 'patch'
	data = get(obj(j),'vertices');
	data = data(:,3);
       case 'image'
	prototype='ignore';
	data = 1;
      end
     case 'y'
      proptype = 'AlphaData';
      switch get(obj(j), 'type')
       case 'surface'
	z = get(obj(j),'zdata');
	y = get(obj(j),'ydata');
	if  ~isequal(size(y), size(z))
	  data = repmat(y, [1 size(z,2)]);
	else
	  data = y;
	end
       case 'patch'
	data = get(obj(j),'vertices');
	data = data(:,2);
       case 'image'
	prototype='ignore';
	data = 1;
      end
     case 'x'
      proptype = 'AlphaData';
      switch get(obj(j), 'type')
       case 'surface'
	z = get(obj(j),'zdata');
	x = get(obj(j),'xdata');
	if  ~isequal(size(x), size(z))
	  data = repmat(x, [size(z,1) 1]);
	else
	  data = x;
	end
       case 'patch'
	data = get(obj(j),'vertices');
	data = data(:,1);
       case 'image'
	prototype='ignore';
	data = 1;
      end
     case 'color'
      proptype = 'AlphaData';
      switch get(obj(j), 'type')
       case 'patch'
	data = get(obj(j),'facevertexcdata');
       otherwise
	data = get(obj(j),'cdata');
      end
      if size(data,3) == 3
        if strcmp(which('rgb2ind'),'')
          error('Cannot convert RGB color data to Alpha Data');
        else
          data=rgb2ind(data,get(gcf,'colormap'));
        end
      end
      if sum(size(data)) == 0
	% single color patches will end up in the middle of
	% the colormap.
	prototype = 'FaceAlpha';
	data = .5;
      end
     case 'rand'
      switch get(obj(j), 'type')
       case 'patch'
	data = get(obj(j),'vertices');
	data = rand(size(data,1), 1);
       otherwise
	data = get(obj(j),'cdata');
	data = rand(size(data));
      end
      proptype = 'AlphaData';
     case 'scaled'
      data = param1;
      proptype = 'AlphaDataMapping';
     case 'direct'
      data = param1;
      proptype = 'AlphaDataMapping';
     case 'none'
      data = param1;
      proptype = 'AlphaDataMapping';
     otherwise
      if ischar(param1)
	p = str2num(param1);
	if ~isempty(p)
	  data=p;
	else
	  data=param1;
	end
      else
	data=param1;
      end
      
      if isa(data, 'double') & sum(size(data) == 1) == 2
	proptype = 'FaceAlpha';
      elseif isa(data, 'double') | isa(data,'uint8')
	proptype = 'AlphaData';
      else
	error('Unknown value for Alpha.');
      end
    end
  end

  switch proptype
    case 'FaceAlpha'
     % Face Alpha type behavior is different for scalar alphadata
     % on images
     switch get(obj(j),'type')
      case 'image'
       set(obj(j),'AlphaData', [ data ]);
      otherwise
       set(obj(j),'FaceAlpha', data);
     end
   case 'AlphaData'
    % Alpha Data is set on patches differently
    switch get(obj(j),'type')
     case 'patch'
      set(obj(j), 'FaceVertexAlphaData', data);
     otherwise
      set(obj(j), 'AlphaData', data);
    end
    % Once data is set, make sure we switch to flat alpha,
    % otherwise it's not very useful.
    switch get(obj(j),'type')
     case 'image'
     otherwise
      if isa(get(obj(j), 'facea'),'double')
	set(obj(j),'facea','flat');
      end
    end
   case 'AlphaDataMapping'
    % AlphaData mapping is nice and simple.
    set(obj(j),'AlphaDataMapping',data);
   otherwise
    % Hmm, whats up with that.
    disp('Unknown property type found.');
  end
end



