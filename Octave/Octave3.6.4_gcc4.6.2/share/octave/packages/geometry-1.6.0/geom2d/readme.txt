%% Copyright (c) 2011, INRA
%% 2007-2011, David Legland <david.legland@grignon.inra.fr>
%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% All rights reserved.
%% (simplified BSD License)
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice, this
%%    list of conditions and the following disclaimer.
%%     
%% 2. Redistributions in binary form must reproduce the above copyright notice, 
%%    this list of conditions and the following disclaimer in the documentation
%%    and/or other materials provided with the distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.
%%
%% The views and conclusions contained in the software and documentation are
%% those of the authors and should not be interpreted as representing official
%% policies, either expressed or implied, of copyright holder.


Description of the geom2d library.

The aim of geom2d library is to handle and visualize geometric primitives such
as points, lines, circles and ellipses, polylines and polygons...  It provides
low-level functions for manipulating geometrical primitives, making easier the
development of more complex geometric algorithms.   
 
Some features of the library are:
 
- creation of various shapes (points, circles, lines, ellipses, polylines,
    polygons...) through an intuitive syntax. 
    Ex: createCircle(p1, p2, p3) to create a circle through 3 points.  
 
- derivation of new shapes: intersection between 2 lines, between line and
    circle, between polylines... or point on a curve from its parametrisation
 
- functions for polylines and polygons: compute centroid and area, expand, 
    self-intersections, clipping with half-plane...  
 
- manipulation of planar transformation. Ex.:
    ROT = createRotation(CENTER, THETA);
    P2 = transformPoint(P1, ROT);  
 
- direct drawing of shapes with specialized functions. Clipping is performed 
    automatically for infinite shapes such as lines or rays. Ex:
    drawCircle([50 50 25]);     % draw circle with radius 25 and center [50 50]
    drawLine([X0 Y0 DX DY]);    % clip and draw straight line
 
- measure distances (between points, a point and a line, a point and a group
    of points), angle (of a line, between 3 points), or test geometry (point
    on a line, on a circle).  
 
Additional help is provided in geom/Contents.m file, as well as summary files
    like 'points2d.m' or 'lines2d.m'.
