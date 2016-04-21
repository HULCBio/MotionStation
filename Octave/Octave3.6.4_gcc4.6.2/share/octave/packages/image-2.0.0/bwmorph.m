## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{BW2} =} bwmorph (@var{BW}, @var{operation})
## @deftypefnx {Function File} {@var{BW2} =} bwmorph (@var{BW}, @var{operation}, @var{n})
## Perform a morphological operation on a binary image.
##
## BW2=bwmorph(BW,operation) performs a morphological operation
## specified by @var{operation} on binary image @var{BW}. All possible
## operations and their meaning are specified in a table below.
##
## BW2=bwmorph(BW,operation,n) performs a morphological operation
## @var{n} times. Keep in mind that it has no sense to apply some
## operations more than once, since some of them return the same result
## regardless how many iterations we request. Those return a warning if
## are called with n>1 and they compute the result for n=1.
##
## @var{n}>1 is actually used for the following operations: diag,
## dilate, erode, majority, shrink, skel, spur, thicken and thin.
##
## @table @code
## @item 'bothat'
## Performs a bottom hat operation, a closing operation (which is a
## dilation followed by an erosion) and finally substracts the original
## image.
##
## @item 'bridge'
## Performs a bridge operation. Sets a pixel to 1 if it has two nonzero
## neighbours which are not connected, so it "bridges" them. There are
## 119 3-by-3 patterns which trigger setting a pixel to 1.
##
## @item 'clean'
## Performs an isolated pixel remove operation. Sets a pixel to 0 if all
## of its eight-connected neighbours are 0.
##
## @item 'close'
## Performs closing operation, which is a dilation followed by erosion.
## It uses a ones(3) matrix as structuring element for both operations.
##
## @item 'diag'
## Performs a diagonal fill operation. Sets a pixel to 1 if that
## eliminates eight-connectivity of the background.
##
## @item 'dilate'
## Performs a dilation operation. It uses ones(3) as structuring element.
##
## @item 'erode'
## Performs an erosion operation. It uses ones(3) as structuring element.
##
## @item 'fill'
## Performs a interior fill operation. Sets a pixel to 1 if all
## four-connected pixels are 1.
##
## @item 'hbreak'
## Performs a H-break operation. Breaks (sets to 0) pixels that are
## H-connected.
##
## @item 'majority'
## Performs a majority black operation. Sets a pixel to 1 if five
## or more pixels in a 3-by-3 window are 1. If not it is set to 0.
##
## @item 'open'
## Performs an opening operation, which is an erosion followed by a
## dilation. It uses ones(3) as structuring element.
##
## @item 'remove'
## Performs a iterior pixel remove operation. Sets a pixel to 0 if 
## all of its four-connected neighbours are 1.
##
## @item 'shrink'
## Performs a shrink operation. Sets pixels to 0 such that an object
## without holes erodes to a single pixel (set to 1) at or near its
## center of mass. An object with holes erodes to a connected ring lying
## midway between each hole and its nearest outer boundary. It preserves
## Euler number.
##
## @item 'skel'
## Performs a skeletonization operation. It calculates a "median axis
## skeleton" so that points of this skeleton are at the same distance of
## its nearby borders. It preserver Euler number. Please read
## compatibility notes for more info.
##
## It uses the same algorithm as skel-pratt but this could change for
## compatibility in the future.
##
## @item 'skel-lantuejol'
## Performs a skeletonization operation as described in Gonzalez & Woods
## "Digital Image Processing" pp 538-540. The text references Lantuejoul
## as authour of this algorithm.
##
## It has the beauty of being a clean and simple approach, but skeletons
## are thicker than they need to and, in addition, not guaranteed to be
## connected.
##
## This algorithm is iterative. It will be applied the minimum value of
## @var{n} times or number of iterations specified in algorithm
## description. It's most useful to run this algorithm with @code{n=Inf}.
##
## @item 'skel-pratt'
## Performs a skeletonization operation as described by William K. Pratt
## in "Digital Image Processing".
##
## @item 'spur'
## Performs a remove spur operation. It sets pixel to 0 if it has only
## one eight-connected pixel in its neighbourhood.
##
## @item 'thicken'
## Performs a thickening operation. This operation "thickens" objects
## avoiding their fusion. Its implemented as a thinning of the
## background. That is, thinning on negated image. Finally a diagonal
## fill operation is performed to avoid "eight-connecting" objects.
##
## @item 'thin'
## Performs a thinning operation. When n=Inf, thinning sets pixels to 0
## such that an object without holes is converted to a stroke
## equidistant from its nearest outer boundaries. If the object has
## holes it creates a ring midway between each hole and its near outer
## boundary. This differ from shrink in that shrink converts objects
## without holes to a single pixels and thin to a stroke. It preserves
## Euler number.
##
## @item 'tophat'
## Performs a top hat operation, a opening operation (which is an
## erosion followed by a dilation) and finally substracts the original
## image.
## @end table
##
## Some useful concepts to understant operators:
##
## Operations are defined on 3-by-3 blocks of data, where the pixel in
## the center of the block. Those pixels are numerated as follows:
##
## @multitable @columnfractions 0.05 0.05 0.05
## @item X3 @tab X2 @tab X1
## @item X4 @tab  X @tab X0
## @item X5 @tab X6 @tab X7
## @end multitable
##
## @strong{Neighbourhood definitions used in operation descriptions:}
## @table @code
## @item 'four-connected'
## It refers to pixels which are connected horizontally or vertically to
## X: X1, X3, X5 and X7.
## @item 'eight-connected'
## It refers to all pixels which are connected to X: X0, X1, X2, X3, X4,
## X5, X6 and X7.
## @end table
## 
## @strong{Compatibility notes:}
## @table @code
## @item 'fill'
## Checking MATLAB behaviour is needed because its documentation doesn't
## make clear if it creates a black pixel if all eight-connected pixels
## are black or if four-connected suffice (as we do currently following
## Pratt's book).
## @item 'skel'
## Algorithm used here is described in Pratt's book. When applying it to
## the "circles" image in MATLAB documentation, results are not the
## same. Perhaps MATLAB uses Blum's algoritm (for further info please
## read comments in code).
## @item 'skel-pratt'
## This option is not available in MATLAB.
## @item 'skel-lantuejoul'
## This option is not available in MATLAB.
## @item 'thicken'
## This implementation also thickens image borders. This can easily be
## avoided i necessary. MATLAB documentation doesn't state how it behaves.
## @end table
##
## References:
## W. K. Pratt, "Digital Image Processing"
## Gonzalez and Woods, "Digital Image Processing"
##
## @seealso{imdilate, imerode, imtophat, imbothat, makelut, applylut}
## @end deftypefn

## TODO: As soon as Octave doesn't segfault when assigning values to a
## TODO: bool matrix, remove all conversions from lut to logical and
## TODO: just create it as a logical from the beginning.

## TODO: n behaviour should be tested in all cases for compatibility.

function BW2 = bwmorph (BW, operation, n = 1)
  if(nargin<2 || nargin>3)
    print_usage;
  elseif(n<0)
    error("bwmorph: n should be > 0");
  elseif(n==0) ## we'll just return the same matrix (check this!)
    BW2=BW;
  endif

  ## post processing command
  postcmd="";
    
  switch(operation)
    case('bothat')
      se  = ones(3);
      BW2 = imbothat (BW, se);
      if(n>1)
        ## TODO: check if ignoring n>1 is ok. Should I just ignore it
        ## TODO: without a warning?
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('bridge')
      ## see __bridge_lut_fun__ for rules
      ## lut=makelut("__bridge_lut_fun__",3);
      lut=logical([0;0;0;0;0;0;0;0;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;1;1;1;1;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   1;1;1;1;1;1;1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   1;1;1;1;1;1;1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;0;0;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      BW2=applylut(BW, lut);
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('clean')
      ## BW(j,k)=X&&(X0||X1||...||X7)
      ## lut=makelut(inline("x(2,2)&&any((x.*[1,1,1;1,0,1;1,1,1])(:))","x"),3);
      ## which is the same as...
      lut=repmat([zeros(16,1);ones(16,1)],16,1);  ## identity
      lut(17)=0;                                  ## isolated to 0
      ## I'd prefer to create lut directly as a logical, but assigning a
      ## value to a logical segfaults 2.1.57. We'll change it as soon as
      ## it works.
      BW2=applylut(BW, logical(lut));
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('close')
      se  = ones(3);
      BW2 = imclose (BW, se);
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('diag')
      ## see __diagonal_fill_lut_fun__ for rules
      ## lut=makelut("__diagonal_fill_lut_fun__",3);
      lut=logical([0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;0;0;1;1;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;0;0;1;1;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;0;0;1;1;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;0;0;1;1;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;1;1;0;0;0;0;0;0;1;1;0;0;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      cmd="BW2=applylut(BW, lut);";
      

    case('dilate')
      cmd="BW2=imdilate(BW, ones(3));";

    case('erode')
      cmd="BW2=imerode(BW, ones(3));";
      
    case('fill')
      ## lut=makelut(inline("x(2,2)||(sum((x&[0,1,0;1,0,1;0,1,0])(:))==4)","x"),3);
      ## which is the same as...
      lut=repmat([zeros(16,1);ones(16,1)],16,1); ## identity
      ## 16 exceptions
      lut([171,172,175,176,235,236,239,240,427,428,431,432,491,492,495,496])=1;
      BW2=applylut(BW, logical(lut));
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;


    case('hbreak')
      ## lut=makelut(inline("x(2,2)&&!(all(x==[1,1,1;0,1,0;1,1,1])||all(x==[1,0,1;1,1,1;1,0,1]))","x"),3);
      ## which is the same as
      lut=repmat([zeros(16,1);ones(16,1)],16,1); ## identity
      lut([382,472])=0;                          ## the 2 exceptions
      BW2=applylut(BW, logical(lut));
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('majority')
      ## lut=makelut(inline("sum((x&ones(3,3))(:))>=5"),3);
      lut=logical([0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                   0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;
                   0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;0;0;1;0;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                   0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      cmd="BW2=applylut(BW, lut);";

    case('open')
      se  = ones(3);
      BW2 = imopen (BW, se);
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;

    case('remove')
      ## lut=makelut(inline("x(2,2)&&!(sum((x&[0,1,0;1,1,1;0,1,0])(:))==5)","x"),3);
      lut=repmat([zeros(16,1);ones(16,1)],16,1); ## identity
      ## 16 qualifying patterns
      lut([187,188,191,192,251,252,255,256,443,444,447,448,507,508,511,512])=0;
      BW2=applylut(BW, logical(lut));
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;
      
    case('shrink')
      ## lut1=makelut("__conditional_mark_patterns_lut_fun__",3,"S");
      lut1=logical([0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;0;1;1;1;1;0;1;0;0;1;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;1;1;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;1;1;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;0;0;1;1;0;0]);
      ## lut2=makelut(inline("!m(2,2)||__unconditional_mark_patterns_lut_fun__(m,'S')","m"),3);
      lut2=logical([1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;0;1;0;0;0;1;0;0;0;0;0;1;0;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;1;0;0;0;0;0;0;1;1;0;0;1;0;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;1;1;0;0;0;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;0;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;0;1;0;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;0;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;1;1;0;1;0;0;1;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;0;1;0;1;1;1;0;1;0;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;0;1;0;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;0;0;1;0;1;0;0;1;0;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;0;0;0;1;0;1;0;0;1;0;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      cmd="BW2=BW&applylut(applylut(BW, lut1), lut2);";

    case({'skel','skel-pratt'})
      ## WARNING: Result doesn't look as MATLAB's sample. It has been
      ## WARNING: coded following Pratt's guidelines for what he calls
      ## WARNING: is a "reasonably close approximation". I couldn't find
      ## WARNING: any bug.
      ## WARNING: Perhaps MATLAB uses Blum's algorithm (which Pratt
      ## WARNING: refers to) in: H. Blum, "A Transformation for
      ## WARNING: Extracting New Descriptors of Shape", Symposium Models
      ## WARNING: for Perception of Speech and Visual Form, W.
      ## WARNING: Whaten-Dunn, Ed. MIT Press, Cambridge, MA, 1967.

      ## lut1=makelut("__conditional_mark_patterns_lut_fun__",3,"K");
      lut1=logical([0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;0;1;1;1;1;0]);

      ## lut2=makelut(inline("!m(2,2)||__unconditional_mark_patterns_lut_fun__(m,'K')","m"),3);
      lut2=logical([1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;0;1;0;0;0;1;0;1;1;0;0;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;0;0;0;1;1;0;0;1;1;0;0;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;1;0;1;0;0;0;1;0;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;1;0;1;1;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;0;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;1;0;1;0;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;1;1;0;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;0;1;0;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      cmd="BW2=BW&applylut(applylut(BW, lut1), lut2);";
      postcmd="BW2=bwmorph(BW2,'bridge');";

    case('skel-lantuejoul')
      ## init values
      se=ones(3,3);              ## structuring element used everywhere
      BW2=zeros(size(BW));       ## skeleton result
      eBW=BW;                    ## eBW will hold k-times eroded BW
      i=1;
      while i<=n
        if(!any(eBW))            ## if erosion result is 0-matrix then
          break;                 ## we are over
        endif
        BW2|=eBW-dilate(erode(eBW, se), se); ## eBW - opening operation on eBW
                                             ## contributes to skeleton
        eBW=erode(eBW,se);
        i++;
      endwhile
      return;                    ## no general loop in this case

    case('spur')
      ## lut=makelut(inline("xor(x(2,2),(sum((x&[0,1,0;1,0,1;0,1,0])(:))==0)&&(sum((x&[1,0,1;0,0,0;1,0,1])(:))==1)&&x(2,2))","x"),3);
      ## which is the same as
      lut=repmat([zeros(16,1);ones(16,1)],16,1); ## identity
      lut([18,21,81,273])=0; ## 4 qualifying patterns
      lut=logical(lut);
      cmd="BW2=applylut(BW, lut);";

    case('thicken')
      ## This implementation also "thickens" the border. To avoid this,
      ## a simple solution could be to add a border of 1 to the reversed
      ## image.
      BW2=bwmorph(!BW,'thin',n);
      BW2=bwmorph(BW2,'diag');
      return;

    case('thin')
      ## lut1=makelut("__conditional_mark_patterns_lut_fun__",3,"T");
      lut1=logical([0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;1;1;0;0;1;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;0;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;0;1;1;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;0;0;0;0;0;0;0;0;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;1;1;0;1;0;0;0;1;
                    0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;1;0;1;1;1;1;0;0;1;1;0;0]);
      ## lut2=makelut(inline("!m(2,2)||__unconditional_mark_patterns_lut_fun__(m,'T')","m"),3);
      lut2=logical([1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;1;1;0;1;0;1;1;0;0;0;0;1;0;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;1;1;0;0;0;0;0;1;1;0;0;1;0;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;1;1;1;0;0;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;0;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;1;0;1;0;0;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;1;1;0;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;1;1;0;1;0;0;1;0;1;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;0;1;0;1;1;1;0;1;0;1;0;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;0;1;0;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;0;1;0;0;1;0;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;1;0;1;0;0;1;0;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;0;1;1;1;1;1;1;1;
                    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1]);
      cmd="BW2=BW&applylut(applylut(BW, lut1), lut2);";


    case('tophat')
      se  = ones(3);
      BW2 = imtophat (BW, se);
      if(n>1)
        ## TODO: check if ignoring n>1 is ok.
        disp("WARNING: n>1 has no sense here. Using n=1. Please fill a bug if you think this behaviour is not correct");
      endif
      return;


    otherwise
      error("bwmorph: unknown operation type requested.");
  endswitch

  ## we use this assignment because of the swap operation inside the
  ## while.
  BW2=BW;

  ## if it doesn't change we don't need to process it further
  i=1;
  while(i<=n) ## for wouldn't work because n can be Inf
    [BW,BW2]=swap(BW,BW2);
    eval(cmd);
    if(all((BW2==BW)(:)))
      break
    endif
    i+=1;
  endwhile

  ## process post processing commands if needed
  if (isempty (postcmd))
    eval(postcmd);
  endif

endfunction

function [b, a] = swap (a, b)
endfunction

%!demo
%! bwmorph(ones(11),'shrink', Inf)
%! # Should return 0 matrix with 1 pixel set to 1 at (6,6)

## TODO: code tests 


## Test skel-lantuejoul using Gozalez&Woods example (fig 8.39)
%!shared slBW, rslBW
%! uint8(0); # fail for 2.1.57 or less instead of crashing later
%! slBW=logical(zeros(12,7));
%! slBW(2,2)=true;
%! slBW(3:4,3:4)=true;
%! rslBW=slBW;
%! slBW(5:6,3:5)=true;
%! slBW(7:11,2:6)=true;
%! rslBW([6,7,9],4)=true;

%!assert(bwmorph(slBW,'skel-lantuejoul',1),[rslBW(1:5,:);logical(zeros(7,7))]);
%!assert(bwmorph(slBW,'skel-lantuejoul',2),[rslBW(1:8,:);logical(zeros(4,7))]);
%!assert(bwmorph(slBW,'skel-lantuejoul',3),rslBW);
%!assert(bwmorph(slBW,'skel-lantuejoul',Inf),rslBW);
