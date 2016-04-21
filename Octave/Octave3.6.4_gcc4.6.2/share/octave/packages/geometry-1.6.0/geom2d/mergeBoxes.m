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
## @deftypefn {Function File} {@var{box} =} mergeBoxes (@var{box1}, @var{box2})
## Merge two boxes, by computing their greatest extent.
## 
#   Example
##
## @example
##   box1 = [5 20 5 30];
##   box2 = [0 15 0 15];
##   mergeBoxes(box1, box2)
##   ans = 
##       0 20 0 30
## @end example
##
## @seealso{boxes2d, drawBox, intersectBoxes}
## @end deftypefn

function bb = mergeBoxes(box1, box2)

  # unify sizes of data
  if size(box1,1) == 1
      box1 = repmat(box1, size(box2,1), 1);
  elseif size(box2, 1) == 1
      box2 = repmat(box2, size(box1,1), 1);
  elseif size(box1,1) != size(box2,1)
      error('geom2d:Error', 'Bad size for inputs');
  end

  # compute extreme coords
  mini = min(box1(:,[1 3]), box2(:,[1 3]));
  maxi = max(box1(:,[2 4]), box2(:,[2 4]));

  # concatenate result into a new box structure
  bb = [mini(:,1) maxi(:,1) mini(:,2) maxi(:,2)];

endfunction

%!test
%! box1 = [5 20 10 25];
%! box2 = [0 15 15 20];
%! res  = [0 20 10 25];
%! bb = mergeBoxes(box1, box2);
%! assert (res, bb, 1e-6);

