function [x,y] = nddirectico(action,numTabDims,tabIsInput,outDims)
%NDDIRECTICO Mask utilities for LookupNDPick block
%

% Rob Aberg,  28-July-1999
% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/10 18:16:34 $

if (nargin == 0)
  action = 'dialog';
end
%
% Action depends on ACTION and OPTION variables
%
switch (action)
 case 'plotdata'
  xOff   = 0.15;
  xScale = 1;
  yOff   = 0;
  yScale = 0.8;

  arrowX = 0.85 + 0.07*[0,0,1,1,2,1,1,0];
  arrowY = 0.50 + 0.03*[-1,1,1,3,0,-3,-1,-1];

  if (tabIsInput==(-1))
    yT = 1/(3 + numTabDims - outDims);
    yl = yT-0.05; yu = yT+0.05;
    patchX = xOff + [ 0.25, 0.35, 0.35, 0.25 ];
    patchY = yOff + [   yl,  yl,  yu,   yu ];
    x  = [ 0.25, 0.5, 0.5, 0.85, NaN, arrowX, NaN, patchX ];
    y  = [   yT,  yT, 0.5, 0.50, NaN, arrowY, NaN, patchY ];
    return;
  end

  switch (outDims)
   case 1
    switch (numTabDims)
     case 1
      x = [0.2, 0.2, NaN, 0.3, 0.3, ...
	   repmat([NaN, 0.2, 0.3],1,9), ... 
	   NaN, 0.25, 0.5, 0.5, 0.85 ]; 
      y = [ yScale * [0.1, 0.9, NaN, 0.1, 0.9, ...
		      reshape([ NaN*ones(1,9); [0.1,0.1]'*[1:9] ],1,27), ...
		      NaN, 0.45, 0.45 ], 0.5, 0.5 ];
      
      patchX = [ 0.2, 0.3, 0.3, 0.2 ];
      patchY = yScale * [ 0.4, 0.4, 0.5, 0.5 ];

     case 2
      xOff = (0.1);
      x = [ xOff+[0.1, 0.7, 0.7, 0.1, 0.1, NaN, ...
		  0.3, 0.3, NaN, 0.4, 0.4, NaN, ...
		  0.1, 0.7, NaN, 0.1, 0.7, NaN, ...
		  0.35 ], 0.6, 0.85 ];
      yOff = (-0.05);
      y = [ yOff+[0.1, 0.1, 0.8, 0.8, 0.1, NaN, ...
		  0.1, 0.8, NaN, 0.1, 0.8, NaN, ...
		  0.3, 0.3, NaN, 0.4, 0.4, NaN, ...
		  0.35 ], 0.5, 0.5 ];

      patchX = xOff + [ 0.3, 0.4, 0.4, 0.3 ];
      patchY = yOff + [ 0.3, 0.3, 0.4, 0.4 ];
      
     case 3
      xOff   = 0.3;
      xScale = 0.5;
      yOff   = 0.3;
      yScale = 0.5;
      dx = sin(pi/6); dy = sin(pi/6);

      x = [ xOff + xScale*[ 0, 1, NaN, 0, 0, NaN, 0, (-dx), NaN, ...
		    0.6, 0.6-dx, NaN, 0.7, 0.7-dx, NaN, ...
		    0-0.6*dx, 1-0.6*dx, NaN, 0-0.7*dx, 1-0.7*dx, NaN, ...
		    0.6-0.6*dx, 0.6-0.6*dx, NaN, 0.7-0.6*dx, 0.7-0.6*dx, ...
		    0.65-0.65*dx ], 0.85 ];

      y = [ yOff + yScale*[ 0, 0, NaN, 0, 1, NaN, 0, (-dy), NaN, ...
		    0, 0-dy, NaN, 0, 0-dy, NaN, ...
		    0-0.6*dy, 0-0.6*dy, NaN, 0-0.7*dy, 0-0.7*dy, NaN, ...
		    0-0.6*dy, 0.8-0.6*dy, NaN, 0-0.6*dy, 0.8-0.6*dy, ...
		    0.8-0.65*dy ], 0.5 ];

      patchX = xOff + xScale*([ 0.6 0.7 0.7 0.6 ]-0.65*dx);
      patchY = yOff + yScale*([ 0.75 0.75 0.85 0.85 ]-0.70*dy);

     otherwise
      % draw 4-D cube:
      %   which is made of 2 connected cubes, 
      %   which in turn are 2 connected squares 

      % vertices
      square = [ 0,0; 0,1; 1,1; 1,0 ];
      cube   = -1 + 2*[ square, zeros(4,1); square, ones(4,1) ];
      hcube  = [ cube; 2*cube ];

      % edges
      sqE    = [ [1:4]', [2:4,1]' ];
      cubeE  = [ sqE; sqE+4; [[1:4]',[5:8]'] ];
      hcubeE = [ cubeE; cubeE+8; [[1:8]',[9:16]'] ];

      % calc 4-D viewing transform
      f3x = -0.55*sin(pi/6); f3y = -0.35*sin(pi/6);
      transVu = [ 0.15,   0,  0,0.42; ...
		  0, 0.15,  0,0.40; ...
		  0,   0,   0,   0; ...
		  0,   0,   0,   1  ];  
      trans32 = [   1,   0, f3x,   0; ...
		    0,   1, f3y,   0; ...
		    0,   0,   0,   0; ...
		    0,   0,   0,   1  ];  

      T = transVu * trans32;

      % transform and extract points

      hcubePts = T * [ hcube, ones(16,1) ]';
      hcubePts = hcubePts(1:2,:)';  % extract x's & y's

      % calc line segment pairs, sep using NaN's

      hcubeSegs = [ hcubePts(hcubeE(:,1),:), hcubePts(hcubeE(:,2),:) ];
      hcubeSegs = [ hcubeSegs, NaN*ones(32,2) ]';
      x = [ hcubeSegs(1:2:190), NaN, 0.50, 0.85 ];
      y = [ hcubeSegs(2:2:190), NaN, 0.47, 0.50 ];

      patchX = [ 0.42, 0.52, 0.52, 0.42 ];
      patchY = [ 0.42, 0.42, 0.52, 0.52 ];

    end

   case 2
    xOff = (0.1);
    x = [ xOff+[0.1, 0.7, 0.7, 0.1, 0.1, NaN, ...
		0.2, 0.2, NaN, 0.5, 0.5, NaN, ...
		0.6, 0.6, NaN, 0.7, 0.7, NaN, ...
		0.35 ], 0.6, 0.85 ];
    yOff = (-0.05);
    y = [ yOff+[0.1, 0.1, 0.8, 0.8, 0.1, NaN, ...
		0.1, 0.8, NaN, 0.1, 0.8, NaN, ...
		0.1, 0.8, NaN, 0.1, 0.8, NaN, ...
		0.35 ], 0.5, 0.5 ];

    patchX = xOff + [ 0.3, 0.4, 0.4, 0.3 ];
    patchY = yOff + [ 0.1, 0.1, 0.8, 0.8 ];

   case 3
    xOff   = 0.3;
    xScale = 0.5;
    yOff   = 0.3;
    yScale = 0.5;
    dx = sin(pi/6); dy = sin(pi/6);

    x = [ xOff + xScale*[ 0, 1, NaN, 0, 0, NaN, 0, (-dx) ] ];
    x = [ x, NaN, 0.5, 0.85 ];
    y = [ yOff + yScale*[ 0, 0, NaN, 0, 1, NaN, 0, (-dy) ] ];
    y = [ y, NaN, 0.5, 0.5  ];

    patchX = xOff + xScale*[ 0.7 0.7-dx 0.7-dx 0.7 ];
    patchY = yOff + yScale*[ 0.0 0.0-dy 0.8-dy 0.8 ];

   otherwise
    x = [ 0.25 0.75 NaN 0.25 0.75 ];
    y = [ 0.25 0.75 NaN 0.75 0.25 ];

    patchX = [ 0.45, 0.55, 0.55, 0.45 ];
    patchY = [ 0.45, 0.45, 0.55, 0.55 ];

  end

  % draw the output arrow, the patches and do block orientations
  
  x = [ x, NaN, arrowX, 0.02+patchX ]; % w/patch fudge
  y = [ y, NaN, arrowY, patchY ];

  switch get_param(gcb,'Orientation')
   case 'right'
   case 'left'
    x = 1 - x;
   case 'up'
    temp = x;
    x = 1 - y;
    y = 0.8*temp;
   case 'down'
    temp = x;
    x = y;
    y = 0.8*(1-temp);
  end
  
 case 'dialog'
  maskVisibilities = get_param(gcb,'MaskVisibilities');
  [ maskVisibilities{[1,3,4,6]} ] = deal('on');
  if strcmp(get_param(gcb,'maskTabDims'),'More...')
    maskVisibilities{2} = 'on';
  else
    maskVisibilities{2} = 'off';
  end
  if strcmp(get_param(gcb,'tabIsInput'),'on')
    maskVisibilities{5} = 'off';
  else
    maskVisibilities{5} = 'on';
  end
  set_param(gcb, 'MaskVisibilities', maskVisibilities);
end
%eof nddirectico.m
