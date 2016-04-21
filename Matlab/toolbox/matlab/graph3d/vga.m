function themap = vga
%VGA    The Windows color map for 16 colors.
%   VGA returns a 16-by-3 matrix containing the colormap
%   used by Windows for 4-bit color. 
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(vga)
%
%   See also HSV, GRAY, HOT, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   P. Fry, 6-25-98.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 04:29:09 $

themap = [1    1    1   
          0.75 0.75 0.75
	  1    0    0   
	  1    1    0   
	  0    1    0   
	  0    1    1   
	  0    0    1   
	  1    0    1   
	  0    0    0   
	  0.5  0.5  0.5 
	  0.5  0    0   
	  0.5  0.5  0   
	  0    0.5  0   
	  0    0.5  0.5 
	  0    0    0.5 
	  0.5  0    0.5]; 