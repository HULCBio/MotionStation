%RECTANGLE   Create rectangle, rounded-rectangle, or ellipse.
%   RECTANGLE adds a default rectangle to the current axes.
%   RECTANGLE('Position', [x y w h]) adds a rectangle at the 
%   specified position.
%
%   RECTANGLE('Curvature', [0 0], ...) creates a rectangle.
%   RECTANGLE('Curvature', [1 1], ...) creates an ellipse.
%   RECTANGLE('Curvature', [x y], ...) creates a rectangle with
%   rounded corners where x and y are between 0 and 1 and represent
%   the normalized amount of curvature.  Horizontal curvature (x)
%   is the fraction of the width of the position rectangle which is
%   curved.  Vertical curvature (y) is the fraction of the height
%   of the position rectangle which is curved.
%
%   RECTANGLE returns a handle to a RECTANGLE object. RECTANGLEs are 
%   children of AXES objects.
%
%   The RECTANGLE object will not render at axes View angles other than
%   [0 90]. 
%
%   Execute GET(H), where H is a rectangle handle, to see a list of 
%   rectangle object properties and their current values. Execute SET(H) 
%   to see a list of rectangle object properties and legal property 
%   values.
%
%   See also LINE, PATCH, TEXT, PLOT, PLOT3.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 17:05:47 $
%   Built-in function.


