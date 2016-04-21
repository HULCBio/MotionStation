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
## @deftypefn {Function File} {@var{T} = } function_name (@var{line})
## Create the the 3x3 matrix of a line reflection.
##
##   Where @var{line} is given as [x0 y0 dx dy], return the affine tansform
##   corresponding to the desired line reflection.
##
##   @seealso{lines2d, transforms2d, transformPoint, 
##   createTranslation, createHomothecy, createScaling}
## @end deftypefn

function trans = createLineReflection(line)

  # extract line parameters
  x0 = line(:,1);
  y0 = line(:,2);
  dx = line(:,3);
  dy = line(:,4);

  # normalisation coefficient of line direction vector
  delta = dx*dx + dy*dy;

  # compute coefficients of transform
  m00 = (dx*dx - dy*dy)/delta; 
  m01 = 2*dx*dy/delta; 
  m02 = 2*dy*(dy*x0 - dx*y0)/delta; 
  m10 = 2*dx*dy/delta; 
  m11 = (dy*dy - dx*dx)/delta; 
  m12 = 2*dx*(dx*y0 - dy*x0)/delta; 

  # create transformation
  trans = [m00 m01 m02; m10 m11 m12; 0 0 1];

endfunction

