## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} drawAxis3d ()
## @deftypefnx {Function File} drawAxis3d (@var{l},@var{r})
## Draw a coordinate system and an origin
##
##  Adds 3 cylinders to the current axis, corresponding to the directions
##  of the 3 basis vectors Ox, Oy and Oz.
##  Ox vector is red, Oy vector is green, and Oz vector is blue.
##
##  @var{l} specifies the length and @var{r} the radius of the cylinders
##  representing the different axes.
##
##  WARNING: This function doesn't work in gnuplot (as of version 4.2).
##
## @seealso{drawAxisCube}
## @end deftypefn

function drawAxis3d(L=1,r=1/10)

  if strcmpi (graphics_toolkit(),"gnuplot")
    error ("geometry:Incompatibility", ...
    ["This function doesn't work with gnuplot (as of version 4.1)." ...
     "Use graphics_toolkit('fltk').\n"]);
  end

  # geometrical data
  origin = [0 0 0];
  v1 = [1 0 0];
  v2 = [0 1 0];
  v3 = [0 0 1];

  # draw 3 cylinders and a ball
  hold on;
  drawCylinder([origin origin+v1*L r], 16, 'facecolor', 'r', 'edgecolor', 'none');
  drawCylinder([origin origin+v2*L r], 16, 'facecolor', 'g', 'edgecolor', 'none');
  drawCylinder([origin origin+v3*L r], 16, 'facecolor', 'b', 'edgecolor', 'none');
  drawSphere([origin 2*r], 'faceColor', 'black');

endfunction
