function [lat,long,splitpts] = clipdata(lat,long,object)
%CLIPDATA  Clip map data at the -pi to pi border of a display
%
%  [lat,long,splitpts] = CLIPDATA(lat,long,'object') inserts
%  NaNs at the appropriate locations in a map object so that a
%  displayed map is clipped at the appropriate edges.  It assumes
%  that the clipping occurs at +/- pi/2 radians in the latitude (y)
%  direction and +/- pi radians in the longitude (x) direction.
%
%  The input data must be in radians and properly transformed
%  for the particular aspect and origin so that it fits in the
%  specified clipping range.
%
%  The output data is in radians, with clips placed at the proper
%  locations.  The output variable splitpts returns the row and column
%  indices of the clipped elements (columns 1 and 2 respectively).
%  These indices are necessary to restore the original data if the
%  map parameters or projection are ever changed.
%
%  Allowable object strings are: 'surface' for clipping graticules;
%  'light' for clipping lights; 'line' for clipping lines;
%  'patch' for clipping patches; 'text' for clipping text object
%  location points; 'point' for clipping point data; and 'none' 
%  to skip all clipping operations
%
%  See also TRIMDATA, UNDOCLIP, UNDOTRIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.17.4.1 $ $Date: 2003/08/01 18:17:54 $
%  Written by:  E. Byrns, E. Brown

%  Argument tests
checknargin(3,3,nargin,mfilename);

%if isempty(lat) | isempty(long)
%   splitpts = [];
%   return
%end

%  Switch according to the correct object

switch object
case 'surface'
   [lat,long,splitpts] = clipgrat(lat,long);
   
case 'line'
   [lat,long,splitpts] = clipline(lat,long);
   
case 'point'       %  No clipping needed for point data
   splitpts = [];
   
case 'text'       %  No clipping needed for point data
   splitpts = [];
   
case 'light'       %  No clipping needed for light data
   splitpts = [];
   
case 'none'       %  No clipping needed option
   splitpts = [];
   
case 'patch'
   
   %  Process the patches one at a time.  The patch data will be a vector
   %  at this point, but individual patches may be NaN-separated in this
   %  vector data.
   
   indx = find(isnan(lat) | isnan(long));
   if isempty(indx);  
      indx = length(lat)+1;  
   end
   latout = [];  lonout = [];
   
   %  Set the clipflag save indicator.  If any patch in the vector data
   %  is clipped, then the entire data set must be saved as the splitpts.
   %  This is because the clipped patch will have many data points inserted
   %  into the vector, which makes the bookkeeping difficult (especially with
   %  the interpm step).  So, with clipped patches, the entire data set is
   %  simply saved as a method of reconstructing the data via setm.  (See
   %  also undoclip).
   
   clippedflag = 0;
   
   %  Loop through each patch
   
   for i = 1:length(indx)
      
      if i == 1;     
         startloc = 1;
      else;      
         startloc = indx(i-1)+1;
      end
      endloc = indx(i)-1;
      
      
      behavior = 'new';
      
      switch behavior
      case 'old'
         % This method was used in versions 1.0 and 1.01. The logic of which
         % pole should be the target of the branch cut for patches that 
         % encompass the pole was not foolproof. Furthurmore, there were
         % rare occasions when the branch cut would not be executed properly,
         % resulting in a wild sinusoidal swoop across the map. 
         %
         % For this reason, the algorithm reimplemented using the assumption
         % that the patch encompasses pole it which it spends the most time.
         % This is estimated based on the geographic mean of the edge points
         % (interpolated to a minimum spacing). The branch cut and clipping
         % logic is a fixed sequence of interpolations and concatenations,
         % and requires none of the numerical fiddling of the old method.
         % While not foolproof either, the new method is more reliable, less 
         % ad-hoc, and marginally faster that the old. It will fail with 
         % patches that encompass more than a hemisphere, that have more 
         % points in the opposite hemisphere, or encompass more than one 
         % pole. It will also fail with self-intersecting patches.
         %
         % To restore the old behavior, set the above variable to 'old'.
         
         
         %  Clip the individual patch if it crosses the dateline.  Make sure that
         %  the patch closes on itself by repeating the first point at the end
         %  of the vector data.
         
         [latseg,lonseg,clipped] = clippatch(lat([startloc:endloc startloc]),...
            long([startloc:endloc startloc]));
         
         %  If the patch crosses the dateline, then continue to process the
         %  data so that two patches are returned, separated by a single NaN in
         %  the data vectors.  This processing must account for the possiblity
         %  that a patch will need to be dropped to the poles to properly close
         %  the polygon.
         
         if clipped
            clippedflag = 1;                                       %  Flag to save the entire data set
            [latseg,lonseg,dropflag] = setdrop90(latseg,lonseg);   %  Determine split type
            [latseg,lonseg] = movetobreak(latseg,lonseg);          %  Move clips to dateline
            [latseg,lonseg] = reorder(latseg,lonseg);              %  Reorder patch segments
            [latseg,lonseg] = drop90(latseg,lonseg,dropflag);      %  Process pole drops
            [latseg,lonseg]= interpm(latseg,lonseg,pi/180);        %  Fill in to 1-degree spacing
         end
         
      case 'new'
         [latseg,lonseg,clipped] = clippatch2(lat([startloc:endloc startloc]),...
            long([startloc:endloc startloc]));
         if clipped; clippedflag = 1; end											%  Flag to save the entire data set
      end
      
      if i == 1
         latout = [latseg; NaN];
         lonout = [lonseg; NaN];
      else
         latout = [latout; latseg; NaN];
         lonout = [lonout; lonseg; NaN];
      end
      
   end  % end for loop
   
   %  Set the output vectors
   
   if clippedflag;
      splitpts = [lat long];  
   else;
      splitpts = [];  
   end
   lat = latout;
   long = lonout;
   
otherwise
   eid = sprintf('%s:%s:invalidObject', getcomp, mfilename);
   error(eid,'%s%s','Unrecognized object:  ',object)
   
end  % end switch


%*********************************************************************
%*********************************************************************
%*********************************************************************


function [yout,xout,splitpts] = clipgrat(ymat,xmat)

%CLIPGRAT:  NaN clip graticules for surface meshes
%
%  Purpose
%
%  CLIPGRAT will insert NaNs at the appropriate locations in a
%  surface graticule mesh so that a displayed map is clipped at
%  the appropriate edges.  It assumes that the clipping occurs
%  at +/- pi/2 radians in the latitude (y) direction and +/- pi
%  radians in the longitude (x) direction.
%
%  For graticules, clip points are NaNs which overwrite
%  a point at the clip location.  This approach does not alter
%  the dimensions of the underlying graticule, which in turn,
%  does not stretch or compress the displayed map.  However,
%  data will not be displayed at the clipped edges of the map.
%
%  The input data must be in radians and be properly transformed
%  for the particular aspect and origin so that it fits in the
%  specified clipping range.
%
%  The output data is in radians, with clips placed at the proper
%  location.  The output variable splitpts returns the index of the
%  clipped elements (column 1, vector indexing for the matrices) and
%  the original latitude and longitude data (columns 2 and 3 respectively)
%  from the unclipped inputs.  These original data are necessary to
%  restore the graticule if the map parameters or projection are
%  ever changed.
%
%  Synopsis
%
%       [latc,longc,splitpts] = clipgrat(lat,long)
%
%       See also CLIPLINE, CLIPPATCH, CLIPDATA


%  Programmers Note:
%
%  Unlike lines and grids where a NaN is inserted into the array,
%  a graticule has the clip point simply replaced by a NaN.  
%  Since a surface map is drawn with the map data in the Cdata property,
%  altering the underlying graticule (Xdata, Ydata, Zdata), will stretch
%  and modify the displayed map.  By the time the clips are performed,
%  the graticule grid must be defined.  So, with graticules, a NaN 
%  is simply inserted into the the location of a clip crossing, and thus,
%  not altering the already existing graticule grids.
%  
%  The resulting display will drop data at the edge of the display when
%  a NaN is encountered.  To decrease this effect, decrease the graticule
%  size (increase the number of graticule points) and the amount of data
%  dropped at the edge of the map will decrease.
%
%  For regular matrix maps, another approach is to pre-warp the graticule 
%  and map (newpole) before displaying the data.  This will cause the 
%  graticule to be properly aligned with the edges of the display and hence 
%  no clips will occur.  The resulting display will not have any dropped data.


%  Argument tests
checknargin(2,2,nargin,mfilename);

%  Initialize outputs.  Don't initialize xout and yout because
%  it may mess up the first assignment of clipped data later.

splitpts = [];

%  Error and exception tests

if isempty(xmat)                       %  Must have data
   eid = sprintf('%s:%s:emptyMatrix', getcomp, mfilename);
   error(eid,'%s','Empty x or y matrix')
   
elseif ndims(xmat) > 2                %  Must be n by m matrices
   eid = sprintf('%s:%s:invalidDims', getcomp, mfilename);
   error(eid,'%s','Input matrices can not have pages')
   
elseif ~isequal(size(xmat),size(ymat))     %  Dimensional consistency
   eid = sprintf('%s:%s:invalidSize', getcomp, mfilename);
   error(eid,'%s','Inconsistent dimensions with clip and other matrices.')
   
elseif length(xmat) == 1            %  Scalars don't need to be clipped.
   xout = xmat;     yout = ymat;   %  Scalar's mess up algorithm too.
   return                          
   
elseif size(xmat,1) == 1            %  Algorithm requires column vectors
   xmat = xmat';   ymat = ymat';
end


%  Initialize variables.

breakpoint = pi;            %  Clipping always at -pi / pi border
units      = 'radians';     %  Data always in radians
splitpts   = [ ];           %  Locations of NaN clips
epsilon    = epsm(units);   %  Epsilon region around zero

%  Make copies of original inputs for later retrivial of data.
%  This must be done before the below operations on xmat.

xsave = xmat;     ysave = ymat;

%  Eliminate round-off problems with original data that
%  is near zero.  This seems to help the npi2pi shift,
%  but it has not be conclusively proven to be necessary.

indx = find(abs(xmat) <= epsilon);
xmat(indx) = zeros(size(indx));

%  Shift the input x data so that all clip points now
%  occur across the zero line and not at -pi to pi boundary.

xmat = npi2pi(xmat-breakpoint,units,'exact');

%  Shift points which are almost identically zero to slightly
%  positive.  This helps the npi2pi transformation back to
%  the original coordinates by ensuring that roundoff does not
%  accidently push a point to the wrong side of the zero line.
%  The wrong side of the zero line will become the wrong side
%  of the -pi to pi boundary later.

indx = find(abs(xmat) <= epsilon);
xmat(indx) = epsilon*ones(size(indx));


%  Initialize output matrices.  This must be done after
%  the above operations on xmat.

xout  = xmat;     yout  = ymat;


%*********************************************************
%  First search the graticule for clips along the rows.
%  Then, search the graticule for clips along the columns.
%*********************************************************


%  Find the crossings of the x = 0 line.  These are the locations
%  to be clipped.  Search only in a window slightly greater than
%  pi.  Points outside this range are considered to be connected
%  by the shorter distance around the sphere.  This distance passes
%  through x = 0 in the original system, and hence will not cross
%  the -pi / pi boundary.  The variable splitvec contains the row
%  locations where a clip is to occur.


%***********
%  Row clips
%***********

xtest = diff(sign(xout));
[i,j] = find(xtest ~= 0 & ~isnan(xtest) );

splitvec = i + (j-1)*size(xmat,1);
indx = find(abs(xmat(splitvec) - xmat(splitvec+1)) <= 1.05*pi);
splitvec = splitvec(indx);

%  Replace the point at the clip with a NaNs.  Save a the location
%  of the clip and the original data that was overwritten.

xout(splitvec)   = NaN;     yout(splitvec)   = NaN;
xout(splitvec+1) = NaN;     yout(splitvec+1) = NaN;

splitpts = [splitvec    ysave(splitvec)     xsave(splitvec)
   splitvec+1  ysave(splitvec+1)   xsave(splitvec+1) ];


%**************
%  Column clips
%**************

%  Find the clip points of the transposed matrix.

xtrans = xout';
xtest = diff(sign(xtrans));

[i,j] = find(xtest ~= 0 & ~isnan(xtest) );
splitvec = i + (j-1)*size(xtrans,1);
indx = find(abs(xtrans(splitvec) - xtrans(splitvec+1)) <= 1.05*pi);

%  Determine the index of the clip for the untransposed matrix.

splitvec = j(indx) + (i(indx)-1)*size(xmat,1);

%  Replace the point at the clip with a NaNs.  Save a the location
%  of the clip and the original data that was overwritten.

xout(splitvec)   = NaN;     yout(splitvec)   = NaN;
xout(splitvec+1) = NaN;     yout(splitvec+1) = NaN;

if (isempty(splitpts) & isempty(splitvec))
    splitpts = [];
else
    splitpts = [splitpts 
        splitvec    ysave(splitvec)     xsave(splitvec)
        splitvec+1  ysave(splitvec+1)   xsave(splitvec+1)];
end

%  Transform the x data back to the original zero location.
%  This process moves the clip points to the -pi and pi edges
%  of the data set.

xout = npi2pi(xout+breakpoint,units,'exact');


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [yout,xout,splitpts] = clipline(ymat,xmat)

%CLIPLINE:  NaN clip line maps
%
%  Purpose
%
%  CLIPLINE will insert NaNs at the appropriate locations 
%  in a line map so that a displayed map is clipped at
%  the appropriate edges.  It assumes that the clipping occurs
%  at +/- pi/2 radians in the latitude (y) direction and +/- pi
%  radians in the longitude (x) direction.
%
%  For lines, clip points are NaNs which are inserted into the vector
%  at the clip location.  No extrapolation of the line data to the
%  edge of the map is performed.  If a clipped line terminates too 
%  far from the edge of the display, then the line data should be
%  rescaled to include additional points before the line is plotted.
%
%  The input data must be in radians and properly transformed
%  for the particular aspect and origin so that it fits in the
%  specified clipping range.
%
%  The output data is in radians, with clips placed at the proper
%  location.  The output variable splitpts returns the row and column
%  indices of the clipped elements (columns 1 and 2 respectively).
%  These indices are necessary to restore the original data if the
%  map parameters or projection are ever changed.
%
%  Synopsis
%
%       [latc,longc,splitpts] = clipline(lat,long)
%
%       See also CLIPGRAT, CLIPPATCH, CLIPDATA

%  Programmer's Note:
%
%  Unlike grids (which are considered a special type of line object),
%  a line object should be displayed as given.  No extrapolation of
%  points should be performed.  The user can provide a denser data 
%  set, where the extrapolation is under their control.  This routine,
%  since it is part of the display process, should display (and hence clip)
%  the data as given.
%
%  The extrapolation process used for grids (clipgrid) is extremely
%  robust as long as the lines are fairly well behaved.  However, for
%  complete generality, line objects can not be assumed to always be
%  fairly well behaved.  Sparse data can lead to spurious extrapolations.
%  So, line objects are simply clipped without extrapolations to allow
%  for complete generality.
%
%  Another reason for no extrapolation while clipping occur
%  with symbol plots.  Symbol plots should not be extrapolated
%  when clipped.  This would introduce additional symbols on the plots.
%  This would not be good.

%  Historical note:  clipgrid was an old function where this clipping
%  process originated.  It doesn't exist anymore, but was the basis for 
%  the clippatch algorithm used for patch objects.  So, the extrapolation
%  process referred to above was similar (though not idential) to the
%  extrapolation applied in clippatch.  EVB  3/38/97.

%  Argument tests
checknargin(2,2,nargin,mfilename);

%  Initialize outputs.  Don't initialize xout and yout because
%  it may mess up the first assignment of clipped data later.

splitpts = [];

%  Error and exception tests

if isempty(xmat)                       %  Must have data
   eid = sprintf('%s:%s:emptyMatrix', getcomp, mfilename);
   error(eid,'%s','Empty x or y matrix')
   
elseif ndims(xmat) > 2                %  Must be n by m matrices
   eid = sprintf('%s:%s:invalidDims', getcomp, mfilename);
   error(eid,'%s','Input matrices can not have pages')
   
elseif ~isequal(size(xmat),size(ymat))     %  Dimensional consistency
   eid = sprintf('%s:%s:invalidSize', getcomp, mfilename);
   error(eid,'%s','Inconsistent dimensions with clip and other matrices.')
   
elseif length(xmat) == 1            %  Scalars don't need to be clipped.
   xout = xmat;     yout = ymat;   %  Scalar's mess up algorithm too.
   return                          
   
elseif size(xmat,1) == 1            %  Algorithm requires column vectors
   xmat = xmat';   ymat = ymat';
end


%  Initialize variables.

breakpoint = pi;            %  Clipping always at -pi / pi border
units      = 'radians';     %  Data always in radians
splitpts   = [ ];           %  Locations of NaN clips
epsilon    = epsm(units);   %  Epsilon region around zero
xsave      = xmat;          %  Saved copy on input data

%  Eliminate round-off problems with original data that
%  is near zero.  This seems to help the npi2pi shift,
%  but it has not be conclusively proven to be necessary.

indx = find(abs(xmat) <= epsilon);
xmat(indx) = zeros(size(indx));

%  Shift the input x data so that all clip points now
%  occur across the zero line and not at -pi to pi boundary.

xmat = npi2pi(xmat-breakpoint,units,'exact');

%  Shift points which are almost identically zero to slightly
%  positive.  This helps the npi2pi transformation back to
%  the original coordinates by ensuring that roundoff does not
%  accidently push a point to the wrong side of the zero line.
%  The wrong side of the zero line will become the wrong side
%  of the -pi to pi boundary later.

indx = find(abs(xmat) <= epsilon);
xmat(indx) = -epsilon * sign(xsave(indx));

for i = 1:size(xmat,2)
   
   %  Find the crossings of the x = 0 line.  These are the locations
   %  to be clipped.  Search only in a window slightly greater than
   %  pi.  Points outside this range are considered to be connected
   %  by the shorter distance around the sphere.  This distance passes
   %  through x = 0 in the original system, and hence will not cross
   %  the -pi / pi boundary.  The variable splitvec contains the row
   %  locations where a clip is to occur.
   
   x = xmat(:,i);        y = ymat(:,i);
   
   splitvec = find(diff(sign(x)) ~= 0 );
   indx = find(abs(x(splitvec) - x(splitvec+1)) <= 1.05*pi);
   splitvec = splitvec(indx);
   
   
   %  Clip each crossing of the breakpoint
   %  Interpolate fill points up to epsilon of the actual break location
   
   for j = length(splitvec):-1:1
      
      %  Add data fillers and NaN clip.  Save the location of the NaN clip point.
      %  Adjust the splitpts location to account for the additional
      %  points added to the vector at each breakpoint crossing.
      
      lowerindx = 1:splitvec(j);
      upperindx = splitvec(j)+1:length(x);
      
      x = [x(lowerindx);  NaN; x(upperindx)];
      y = [y(lowerindx);  NaN; y(upperindx)];
      
      %  Note:  The split location in the output vector is saved (column 1 of
      %         splitpts) to facilitate the undoing of the clips.  The
      %         actual line number (column 2) is saved so that LINEM can
      %         associate the clip results with the correct line.  The
      %         split location in the original data (column 3) is saved
      %         so that any Z data associated with this line can be
      %         also be clipped (See mfwdtran for this operation).
      
      splitpts = [splitpts; splitvec(j)+1+(j-1)   i  splitvec(j)];
      
   end     %  End of for loop on splitvec (j variable)
   
   
   %  Build the output matrices.  Account for different number of 
   %  clips in each row of the matrix.  Pad needed spaces with NaNs.
   
   if i == 1 | length(x) == size(xout,1)
      xout(:,i) = x;    yout(:,i) = y;
      
   elseif length(x) < size(xout,1)
      x( length(x)+1:size(xout,1) ) = NaN;
      y( length(y)+1:size(yout,1) ) = NaN;
      
      xout(:,i) = x;    yout(:,i) = y;
      
   elseif length(x) > size(xout,1)
      xout(size(xout,1)+1:length(x), :) = NaN;
      yout(size(yout,1)+1:length(y), :) = NaN;
      
      xout(:,i) = x;     yout(:,i) = y;
   end
   
end     %  End of for loop on input matrix (i variable)

%  Transform the x data back to the original zero location.
%  This process moves the clip points to the -pi and pi edges
%  of the data set.

xout = npi2pi(xout+breakpoint,units,'exact');


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [y,x,clipped] = clippatch(yvec,xvec)

%CLIPPATCH:  NaN clip patches
%
%  Purpose
%
%  CLIPPATCH will insert NaNs at the appropriate locations in
%  latitude and longitude vector data so that a displayed patch is
%  clipped at the appropriate edges.  It assumes that the clipping
%  occurs at +/- pi/2 radians in the latitude (y) direction and 
%  +/- pi radians in the longitude (x) direction.
%
%  For patches, clip points are NaNs which are inserted into the vector
%  at the clip location.  In addition, the line data is extrapolated
%  to the edge of the map.
%
%  The input data must be in radians and properly transformed
%  for the particular aspect and origin so that it fits in the
%  specified clipping range.
%
%  The output data is in radians, with clips placed at the proper
%  location.  The output variable clipped is a flag to indicate that
%  the data set has been clipped.  If so, more processing is necessary
%  for patch objects.
%
%  Synopsis
%
%       [latc,longc,clipped] = clippatch(lat,long)
%
%       See also CLIPGRAT, CLIPLINE, CLIPDATA

%  Programmer's Note:
%
%  CLIPPATCH is the most complicated clipping process (compared
%  to lines and surfaces).  This routine will take a single patch
%  and introduce clips at each dateline crossing.  In addition to
%  putting a NaN at these locations, this routine will also extrapolate
%  the data on either side of the clip.  The extrapolation process
%  produces a new point at either the clip boundary or a pole edge,
%  depending upon which ever is encountered first.  The extrapolation
%  is also dependent upon the direction which the line segment crosses
%  the clip boundary, which is evident from the code below.
%
%  The extrapolation at each boundary crossing is as follows.  Two
%  points must be calculated at each crossing (both sides of the
%  crossing).  The two points leading up to a crossing are used
%  to define the segment direction approaching the crossing.  The
%  extrapolation is performed along the direction defined by these
%  two points.  If the extrapolation process does not terminate at
%  a pole edge, then the point immediately crossing the clip
%  boundary is also determined.  Otherwise, if the extrapolation
%  terminates on a pole edge, then this entire extrapolation process
%  is repeated on the segment immediately after the clip boundary.
%
%  Due to the extrapolation process, this routine is sensitive to
%  sparse patch data.  It is not good to have large separation 
%  (greater that 1 degree or so) between points on the patch.  If
%  the data is sparse, especially around the clip boundary, there is
%  a chance that the extrapolation will be messed up.  To get around
%  this problem, the input data set can be processed via interpm to
%  introduce more points along the patch.


%  Argument tests
checknargin(2,2,nargin,mfilename);

%  Error and exception tests

if isempty(xvec)                           %  Must have data.
   eid = sprintf('%s:%s:emptyMatrix', getcomp, mfilename);
   error(eid,'%s','Empty x or y matrix')
   
elseif ~isequal(size(xvec),size(yvec))     %  Dimensional consistency.
   eid = sprintf('%s:%s:invalidDims', getcomp, mfilename);
   error(eid,'%s','Inconsistent dimensions with clip and other matrices.')
   
elseif any(isnan(xvec) | isnan(yvec))          %  Patches must be separated with single NaNs.
   eid = sprintf('%s:%s:neighboringNaNs', getcomp, mfilename);
   error(eid,'%s','Neighboring NaNs in original data')   %  Results in no NaNs at this point.
   
elseif length(xvec) == 1           %  Scalars don't need to be clipped.
   xout = xvec;                     %  Scalar's mess up algorithm too.
   yout = yvec;   
   clipped = 0;
   return                          
   
end

%  Ensure that the data is in column vector format.
%  Copy the inputs to the working vectors.

xvec = xvec(:);     yvec = yvec(:);
x = xvec;           y = yvec;

%  Initialize variables.

breakpoint = pi;            %  Clipping always at -pi / pi border.
units      = 'radians';     %  Data always in radians.
nanfill    = NaN;           %  Filler data.
clipped    = 0;             %  Data has not been clipped.
epsilon    = epsm(units);   %  Epsilon region around zero.

%  Eliminate round-off problems with original data that
%  is near zero.  This seems to help the npi2pi shift,
%  but it has not be conclusively proven to be necessary.

indx = find(abs(x) <= epsilon);
x(indx) = zeros(size(indx));

%  Shift the input x data so that all clip points now
%  occur across the zero line and not at -pi to pi boundary.

x = npi2pi(x-breakpoint,units,'exact');

%  Shift points which are almost identically zero to slightly
%  positive.  This helps the npi2pi transformation back to
%  the original coordinates by ensuring that roundoff does not
%  accidently push a point to the wrong side of the zero line.
%  The wrong side of the zero line will become the wrong side
%  of the -pi to pi boundary later.

indx = find(abs(x) <= epsilon);
x(indx) = epsilon*ones(size(indx));

%  Find the crossings of the x = 0 line.  These are the locations
%  to be clipped.  Search only in a window slightly greater than
%  pi.  Points outside this range are considered to be connected
%  by the shorter distance around the sphere.  This distance passes
%  through x = 0 in the original system, and hence will not cross
%  the -pi / pi boundary.  The variable splitvec contains the row
%  locations where a clip is to occur.

splitvec = find(diff(sign(x)) ~= 0 );
indx = find(abs(x(splitvec) - x(splitvec+1)) <= 1.05*pi);
splitvec = splitvec(indx);

%  Process the patch data to eliminate single point crossings.  
%  Single point crossings are not handled well by the algorithm.

if ~isempty(splitvec) & length(splitvec) > 1
   [x,y,splitvec] = EliminateSinglePts(x,y,splitvec);
end

%  Clip each crossing of the breakpoint.
%  Extrapolate fill points up to epsilon of the actual break location.
%  This process requires that a anterior point (before clip) and posterior
%  point (after clip) be extrapolated at each clip point.  The location of
%  the anterior and posterior points relative to the clip (right or left) is
%  dependent on the direction of travel when the clip occurs.  The if block
%  below accounts for each combination of right and left travel for both
%  anterior and posterior points.

%  The extrapolation process is two-fold.  First an anterior or posterior point 
%  is computed.  Either the point is determined by extrapolation from the
%  preceeding points or the point is determined by interpolation between
%  the points at the clip location.  For further discussion of this process
%  see the m-files rghtfill and leftfill.

for j = length(splitvec):-1:1
   
   %***********************************************************************
   %  Clipping with insufficient points for the algorithm.  Fill with NaNs.
   %***********************************************************************
   
   if length(xvec) <= 4     
      
      %  At least 4 points are required for the clipping algorithm (2 on
      %  the left side of the clip and 2 on the right side).
      
      %  Test xvec not x since the vector x may grow as points are
      %  added.  However, these added points do not necessarily 
      %  increase the amount of information originally contained in xvec.
      
      xante = NaN;   yante = NaN;
      xpost = NaN;   ypost = NaN;
      
      %****************************************************************
      %  Clipping between first and second point.  Going right to left.
      %****************************************************************
      
   elseif splitvec(j) == 1 & x(splitvec(j)) > x(splitvec(j)+1)
      
      %  Compute the posterior point (after clip) first.  This will occur on
      %  the left side of the clip point (leftfill).
      
      postindx = [splitvec(j)+2 splitvec(j)+1]; 
      interprng = [splitvec(j) splitvec(j)+1];
      [xpost,ypost] = leftfill(x,y,postindx,interprng);
      
      %  Compute the anterior point (before clip).  This will occur on the
      %  right side of the clip point.  Repeat the first point rather than 
      %  call rghtfill since there is no way to extrapolate with only one point.
      
      if length(xpost) == 1
         % Leftfill extrapolated only the point on the left side of the clip.
         xante = x(splitvec(j));    yante = y(splitvec(j));
      else      
         % Leftfill was able to interpolate a point on each side of the clip.
         xante = xpost(2);  xpost(2) = [];
         yante = ypost(2);  ypost(2) = [];
      end
      
      %****************************************************************
      %  Clipping between first and second point.  Going left to right.
      %****************************************************************
      
   elseif splitvec(j) == 1 & x(splitvec(j)) < x(splitvec(j)+1)
      
      %  Compute the posterior point (after clip) first.  This will occur on
      %  the right side of the clip point (rghtfill).
      
      postindx = [splitvec(j)+1 splitvec(j)+2]; 
      interprng = [splitvec(j) splitvec(j)+1];
      [xpost,ypost] = rghtfill(x,y,postindx,interprng);
      
      %  Compute the anterior point (before clip).  This will occur on the 
      %  left side of the clip point.  Repeat the first point rather than 
      %  call leftfill since there is no way to extrapolate with only one point.
      
      if length(xpost) == 1
         % Rghtfill extrapolated only the point on the right side of the clip.
         xante = x(splitvec(j));    yante = y(splitvec(j));
      else      
         % Rghtfill was able to interpolate a point on each side of the clip.
         xante = xpost(2);  xpost(2) = [];
         yante = ypost(2);  ypost(2) = [];
      end
      
      %*********************************************************************
      %  Clipping between last and next to last point.  Going right to left.
      %*********************************************************************
      
   elseif splitvec(j) == length(x)-1 & x(splitvec(j)) > x(splitvec(j)+1)
      
      %  Compute the anterior point (before clip) first.  This will occur on
      %  the right side of the clip point.
      
      anteindx = [splitvec(j) splitvec(j)-1]; 
      interprng = [splitvec(j) splitvec(j)+1];
      [xante,yante] = rghtfill(x,y,anteindx,interprng);
      
      %  Compute the posterior point (after clip).  This will occur on the 
      %  left side of the clip point.  Repeat the last point rather than call 
      %  leftfill because there is no way to extrapolate with only one point.
      
      if length(xante) == 1
         % Rghtfill extrapolated only the point on the right side of the clip.
         xpost = x(splitvec(j)+1);    ypost = y(splitvec(j)+1);
      else      
         % Rghtfill was able to interpolate a point on each side of the clip.
         xpost = xante(2);  xante(2) = [];
         ypost = yante(2);  yante(2) = [];
      end
      
      %*********************************************************************
      %  Clipping between last and next to last point.  Going left to right.
      %*********************************************************************
      
   elseif splitvec(j) == length(x)-1 & x(splitvec(j)) < x(splitvec(j)+1)
      
      %  Compute the anterior point (before clip) first.  This will occur on
      %  the left side of the clip point.
      
      anteindx = [splitvec(j)-1 splitvec(j)];
      interprng = [splitvec(j) splitvec(j)+1];
      [xante,yante] = leftfill(x,y,anteindx,interprng);
      
      %  Compute the posterior point (after clip).  This will occur on the 
      %  right side of the clip point.  Repeat the last point rather than call 
      %  rghtfill because there is no way to extrapolate with only one point.
      
      if length(xante) == 1
         % Leftfill extrapolated only the point on the left side of the clip.
         xpost = x(splitvec(j)+1);    ypost = y(splitvec(j)+1);
      else      
         % Leftfill was able to interpolate a point on each side of the clip.
         xpost = xante(2);  xante(2) = [];
         ypost = yante(2);  yante(2) = [];
      end
      
      %*******************************************************************************
      %  Clipping between between interior points in the vector.  Going right to left.
      %*******************************************************************************
      
   elseif x(splitvec(j)) > x(splitvec(j)+1)
      
      %  Compute the posterior point (after clip) first.  This will occur on
      %  the left side of the clip point.
      
      postindx = [splitvec(j)+2 splitvec(j)+1]; 
      anteindx = [splitvec(j)   splitvec(j)-1]; 
      interprng = [splitvec(j) splitvec(j)+1];
      [xpost,ypost] = leftfill(x,y,postindx,interprng);
      
      %  Compute the anterior point (before clip).  This will occur on
      %  the right side of the clip point.  If leftfill was unable to
      %  interpolate a point on each side of the clip, then call rghtfill.  
      %  If rghtfill is capable of interpolation, then override the posterior
      %  extrapolation of leftfill.
      
      if length(xpost) == 1
         % Leftfill extrapolated only the point on the left side of the clip.
         % Try to interpolate with rghtfill.
         [xante,yante] = rghtfill(x,y,anteindx,interprng);
         if length(xante) ~= 1     
            % Rghtfill was able to interpolate a point on each side of the clip.
            % Therefore, override the posterior extrapolation of leftfill.
            xpost = xante(2);  xante(2) = [];
            ypost = yante(2);  yante(2) = [];
         end
      else      
         % Leftfill was able to interpolate a point on each side of the clip.
         xante = xpost(2);  xpost(2) = [];
         yante = ypost(2);  ypost(2) = [];
      end
      
      %*******************************************************************************
      %  Clipping between between interior points in the vector.  Going left to right.
      %*******************************************************************************
      
   elseif x(splitvec(j)) < x(splitvec(j)+1)
      
      %  Compute the anterior point (before clip) first.  This will occur on
      %  the left side of the clip point.
      
      anteindx = [splitvec(j)-1 splitvec(j)];
      postindx = [splitvec(j)+1 splitvec(j)+2]; 
      interprng = [splitvec(j) splitvec(j)+1];
      [xante,yante] = leftfill(x,y,anteindx,interprng);
      
      %  Compute the posterior point (after clip).  This will occur on
      %  the right side of the clip point.  If leftfill was unable to
      %  interpolate, call rghtfill.  If rghtfill is capable of interpolation, 
      %  then override the posterior extrapolation of leftfill.
      
      if length(xante) == 1
         % Leftfill extrapolated only the point on the left side of the clip.
         % Try to interpolate with rghtfill.
         [xpost,ypost] = rghtfill(x,y,postindx,interprng);
         if length(xpost) ~= 1
            % Rghtfill was able to interpolate a point on each side of the clip.
            % Therefore, override anterior extrapolation of leftfill.
            xante = xpost(2);  xpost(2) = [];
            yante = ypost(2);  ypost(2) = [];
         end
      else      
         % Leftfill was able to interpolate a point on each side of the clip.
         xpost = xante(2);  xante(2) = [];
         ypost = yante(2);  yante(2) = [];
      end
      
   end  % End of the if statement (if length(xvec) <= 4)
   
   
   %  Add data fillers and NaN clip.  Set the clip flag.
   
   lowerindx = 1:splitvec(j);
   upperindx = splitvec(j)+1:length(x);
   
   x = [x(lowerindx);  xante; NaN; xpost; x(upperindx)];
   y = [y(lowerindx);  yante; NaN; ypost; y(upperindx)];
   clipped = 1;
   
end  %  End of for loop on splitvec (j variable)


%  Transform the x data back to the original zero location.
%  This process moves the clip points to the -pi and pi edges
%  of the data set.

x = npi2pi(x+breakpoint,units,'exact');


%**************************************************************************
%**************************************************************************
%**************************************************************************

function [xleft,yleft] = leftfill(x,y,ptindx,interprng)

%  LEFTFILL will fill in points on the left side of
%  a clip.  There are four possible cases, based on
%  the line segment immediately to the left of the 
%  segment that contains the clip:
%
%  1. An endpoint of the segment contains a NaN, and in this case
%     the filled points are set to NaN.  
%
% *2. The line segment to the left of the clip boundary is sloping 
%     away from the crossing.  In this case, extrapolate the line segment 
%     to a pole edge of the map.  *This case removed; Treat the segment to 
%     the left of the clip as if it is heading in the direction of the clip
%     boundary, regardless of the actual direction of the data.
%
%  3. The line segment is sloping towards the clip boundary, but it will 
%     reach the pole edge before reaching the clip boundary.  In this case, 
%     extrapolate to the pole edge of the map.  
%
%  4. The line segment is sloping towards the clip boundary and will cross
%     the clip boundary before hitting the pole edge of the map.  In this 
%     case, interpolate a point on each side of the clip boundary.


epsilon = epsm('radians');
xvec = x(ptindx);     yvec = y(ptindx);


%  Skip the extrapolation steps if either endpoint of the original
%  segment is a NaN.  Simply fill in the interpolation results with
%  a NaN.

if isnan(xvec(1));
   xleft = [NaN NaN];  yleft = [NaN NaN];  return
elseif isnan(xvec(2));
   xleft = [NaN NaN];  yleft = [NaN NaN];  return
end


%  Compute the slope of the line segment to the left of the clip segment.
%  If the line is vertical or nearly vertical (denom = 0), 
%  then set the denom to a very small number.

denom = diff(xvec);
if denom == 0;
   denom = epsilon;
elseif abs(denom) < epsilon;
   denom = sign(denom) * epsilon;
end
slope = diff(yvec) / denom;


%  Compute the slope of a line segment from the second end point
%  up to the pole edge (+/- pi/2) of the map.  This is the testslope  
%  that will be compared with slope to determine if the line segment 
%  will reach the clip boundary or the pole edge first.

denom = abs(xvec(2));
if denom == 0;
   denom = epsilon;
elseif abs(denom) < epsilon;
   denom = sign(denom) * epsilon;
end

%  testslope will be the same sign as slope
testslope = (sign(slope)*pi/2 - yvec(2)) / denom;


%  Compute the left fill points for this segment.

if abs(testslope) >= abs(slope)    
   % Segment will reach the clip boundary before it reaches a pole edge.
   % Interpolate two points, one on each side of the clip boundary.
   xleft = [-epsilon; epsilon];
   yleft  = interp1(x(interprng), y(interprng),0);
   yleft(2) = yleft(1);
else
   if abs(slope) <= epsilon
      % Line segment is nearly horizontal.  Extend the near-horizontal segment
      % to within epsilon of the clip boundary.  (This provides only one fill point.)     
      yleft = yvec(2);                
      xleft = sign(xvec(2))*epsilon;   
   else
      % Segment will reach the pole edge before it reaches the clip boundary.
      % Extrapolate to the pole edge.  (This provides only one fill point.)
      yleft  = sign(slope)*(pi/2);     
      xshift = 0;                     
      xshift = (yleft-yvec(2))/slope;
      xshift = roundn(xshift,-8);
      xleft  = xshift + xvec(2);
   end
end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function [xright,yright] = rghtfill(x,y,ptindx,interprng)


%  RGHTFILL will fill in points on the right side of
%  a clip point.  There are four possible cases, based on .
%  the line segment immediately to the right of the segment 
%  that contains the clip:
%
%  1. An endpoint of the segment contains a NaN, and in this case
%     the filled points are set to NaN.  
%
% *2. The line segment to the right the clip boundary is sloping away from 
%     the crossing.  In this case, extrapolate the line segment to
%     a pole edge of the map.  *This case removed; Treat the segment to 
%     the right of the clip as if it is heading in the direction of the 
%     clip boundary, regardless of the actual direction of the data.
%
%  3. The line segment is sloping towards the clip boundary, but it will 
%     reach the pole edge before reaching the clip boundary.  In this case, 
%     extrapolate to the pole edge of the map.  
%
%  4. The line segment is sloping towards the clip boundary and will cross 
%     the clip boundary before hitting the pole edge of the map.  In this 
%     case, interpolate a point on each side of the clip boundary.


epsilon = epsm('radians');
xvec = x(ptindx);     yvec = y(ptindx);

%  Skip the extrapolation steps if either endpoint of the original
%  segment is a NaN.  Simply fill in the interpolation results with
%  a NaN.

if isnan(xvec(1));
   xright = [NaN NaN];  yright = [NaN NaN];  return
elseif isnan(xvec(2)); 
   xright = [NaN NaN];  yright = [NaN NaN];  return
end


%  Compute the slope of the line segment to the right of the clip segment.  
%  If the line is vertical or nearly vertical (denom = 0), 
%  then set the denom to a very small number.

denom = diff(xvec);
if denom == 0;
   denom = epsilon;
elseif abs(denom) < epsilon;
   denom = sign(denom) * epsilon;
end
slope = diff(yvec) / denom;


%  Compute the slope of a line segment from the second end point
%  up to the pole edge (+/- pi/2) of the map.  This is the testslope 
%  that slope will be compared with to determine if the line segment 
%  will reach the clip boundary or the pole edge first.  The negative 
%  sign is because this is the right fill side.

denom = -xvec(1);
if denom == 0;
   denom = epsilon;
elseif abs(denom) < epsilon;
   denom = sign(denom) * epsilon;
end

%  testslope will be the same sign as slope
testslope = (-sign(slope)*pi/2 - yvec(1) ) / denom;


%  Compute the right fill points for this segment.

if abs(testslope) >= abs(slope)
   % Segment will reach the clip boundary before it reaches a pole edge.
   % Interpolate two points, one on each side of the clip boundary.  
   xright = [epsilon; -epsilon];
   yright = interp1(x(interprng), y(interprng),0);
   yright(2) = yright(1);
else
   if abs(slope) <= epsilon 
      % Line segment is nearly horizontal.  Extend the near-horizontal segment 
      % to within epsilon of the clip boundary.  (This provides only one fill point.)
      yright = yvec(1);   
      xright = sign(xvec(1))*epsilon;
   else
      % Segment will reach the pole edge before it reaches the clip boundary.
      % Extrapolate to the pole edge.  (This provides only one fill point.)
      yright = -sign(slope)*(pi/2);
      xshift = 0;                     
      xshift = (yright-yvec(1))/slope; 
      xshift = roundn(xshift,-8);
      xright = xshift + xvec(1);
   end
end


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [lat,lon,dropflag] = setdrop90(lat,lon)

%  SETDROP90 will initiate the processing of a patch that
%  has been clipped at the date line.  It removes NaNs from 
%  the beginning and end of the segments and then ensures that 
%  the patch vector data begins at a crossing of the date line.
%
%  This function also determines if an even or odd number
%  of crossings of the dateline occurs.  If it is even,
%  then the patch is a closed polygon.  If it is odd,
%  then the patch is a closed polygon only on a sphere
%  (eg:  Antartica is a case like this).  For these patches
%  extra work must be done to drop the first and last
%  point to the nearest pole and then complete the patch
%  in this manner.

epsilon = epsm('radians');
dropflag = 0;


%  Remove NaNs from the beginning and end of the patch.

if isnan(lat(1)) | isnan(lon(1))
   lat(1) = [];
   lon(1) = [];
end

if isnan(lat(length(lat))) | isnan(lon(length(lon)))
   lat(length(lat)) = [];
   lon(length(lon)) = [];
end


%  Ensure that vectors start at a break point.

indx = find(isnan(lat) | isnan(lon));

if abs(abs(lon(1)) - pi) > epsilon
   
   pt1 = indx(1)+1;   
   pt2 = length(lat);
   lat = [lat(pt1:pt2); lat(1:pt1-1)];
   lon = [lon(pt1:pt2); lon(1:pt1-1)];
   
   % Determine the location of the NaN indices after reordering.
   indx = find(isnan(lat) | isnan(lon));
   
end


%  Flag if there is an even number of crossings of the
%  break line.  Each patch closes on itself and does not
%  need to be dropped to the respective pole.

if rem(length(indx),2) == 0;
   dropflag = 0;
else;
   dropflag = 1;
end


%  If there is an odd number of crossings, make sure
%  that the first segment is the one which traverses the
%  map.  This is necessary for the reordering step which
%  will be performed later.  Note that if there is an
%  odd number of crossings, the last point in the vector
%  should be a NaN.

nbreak = length(indx);

if dropflag & nbreak > 1
   
   startpt1 = 1;
   endpt1 = indx(1)-1;
   startpt2 = indx(nbreak-1)+1;
   endpt2 = indx(nbreak)-1;
   
   if sign(lon(startpt1)) == sign(lon(endpt1))        
      % Then the last segment traverses the map.
      indices = [startpt2:endpt2+1 1:startpt2-1];
      lat = lat(indices);
      lon = lon(indices);
   end
   
end


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [lat1,lon1] = movetobreak(lat,lon)

%  MOVETOBREAK will check each clip point of a patch and
%  make sure that it terminates at the dateline of the map.
%  This is necessary because some patches may have been
%  clipped at the pole edge of a map (see CLIPPATCH), and
%  this point does not correspond to the dateline edge of
%  a map.  MOVETOBREAK will take these points and introduce
%  a new point at the dateline of the map.

epsilon = epsm('radians');
indx = find(isnan(lat) | isnan(lon));  %  Determine clip points.

%  Initialize outputs

lat1 = lat;  lon1 = lon;


%  Check each clip point to ensure that it terminates at the dateline.

for i = length(indx):-1:1
   beforelat = [];  beforelon = []; 
   afterlat  = [];  afterlon  = [];  
   
   % Set the before look point.  
   if indx(i) > 1;
      beforeindx = indx(i)-1;
   else;
      beforeindx = [];
   end
   
   % Set the after look point.	  
   if indx(i) < length(lon1);
      afterindx = indx(i)+1; 
   else;
      afterindx = [];  
   end
   
   
   %  Determine if the point before the clip terminates at the dateline.
   
   if ~isempty(beforeindx) & abs(abs(lon(beforeindx)) - pi) > epsilon
      beforelat = lat(beforeindx);
      beforelon = sign(lon(beforeindx)) * (pi-epsilon);
   end
   
   
   %  Determine if the point after the clip terminates at the dateline.
   
   if ~isempty(afterindx) & abs(abs(lon(afterindx)) - pi) > epsilon
      afterlat = lat(afterindx);
      afterlon = sign(lon(afterindx)) * (pi-epsilon);
   end
   
   %  Add the new points to the output vectors (if they are not empty).
   
   lat1 = [lat1(1:beforeindx); beforelat; NaN; afterlat; lat1(afterindx:length(lon1))];
   lon1 = [lon1(1:beforeindx); beforelon; NaN; afterlon; lon1(afterindx:length(lon1))];
   
end  % end for loop


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [lat1,lon1] = reorder(lat,lon)

%  REORDER will take a vector of clipped patch data and reorder
%  the patch segments into at most 2 patches.  This allows
%  the segments which have been clipped to be aligned with
%  their corresponding neighbor sections, thus preserving the
%  shape of the patch, but enforcing the clips.

%  Determine clip points.
indx = find(isnan(lat) | isnan(lon));
nbreak = length(indx);


%  Set start locations for each patch segment.
if nbreak > 1; 
   lower = [1; indx(1:nbreak-1)+1]; 
else;
   % Patch data is already in two segments.
   lower = 1;
end


%  Set end locations for each patch segment.
upper = indx - 1; 


%  Initialize segment variables.
latseg1 = [];  lonseg1 = [];
latseg2 = [];  lonseg2 = [];


%  Partition the clipped patch vector data into two complete patches.

for i = 1:2:length(indx)
   latseg1 = [latseg1; lat(lower(i):upper(i))];
   lonseg1 = [lonseg1; lon(lower(i):upper(i))];
   if i ~= length(indx)
      % i == length(indx) for odd # of crossings
      latseg2 = [latseg2; lat(lower(i+1):upper(i+1))];
      lonseg2 = [lonseg2; lon(lower(i+1):upper(i+1))];
   end
end


%  Construct the output vectors, which will contain at most 2 patches.

if ~isempty(latseg1) & ~isempty(latseg2)
   lat1 = [latseg1; NaN;  latseg2];
   lon1 = [lonseg1; NaN;  lonseg2];
elseif isempty(latseg1) & isempty(latseg2)  
   % when nbreak == 0
   lat1 = lat;
   lon1 = lon;
elseif ~isempty(latseg1)
   lat1 = latseg1;
   lon1 = lonseg1;
elseif ~isempty(latseg2)
   lat1 = latseg2;
   lon1 = lonseg2;
end


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [lat,lon] = drop90(lat,lon,dropflag)

%  DROP90 accomplishes two tasks for the processing of 
%  clipped patches.  First, if necessary, DROP90 will
%  drop the endpoints of a patch that traverses the map
%  so as to close the patch at the corresponding pole.
%  This is necessary whenever an odd number of crossings
%  of the dateline is computed by SETDROP90 (see SETDROP90).
%
%  The second task is to ensure that the clipped patches
%  (whether dropped to a pole or not) are closed.  This is
%  accomplished by ensuring that the first point of each patch
%  is equal to the last point of the patch.

if dropflag      %  Then an odd number of clip crossings are present, 
   %  i.e. a traversing patch segment will need to be 
   %  dropped to a pole to close the patch.
   
   indx = find(isnan(lat) | isnan(lon));   
   if isempty(indx) 
      % Only one patch & no NaNs.
      startpt1 = 1;   endpt1 = length(lat);
      startpt2 = [];  endpt2 = [];
   else
      startpt1 = 1;       endpt1 = indx(1)-1;
      startpt2 = indx+1;  endpt2 = length(lat);
   end
   
   % Drop the traversing patch endpoints to the closest pole.
   
   if sign(lon(startpt1)) ~= sign(lon(endpt1))  % Patch 1 is traversing.
      
      % Determine closest pole.
      signvec = sign(lat([startpt1 endpt1])); 
      indx = find(signvec == 0);
      if ~isempty(indx); 
         signvec(indx) = 1;
      end
      
      % Drop the endpoints to the traversing pole.
      lat = [signvec(1)*pi/2; lat(startpt1:endpt1); signvec(2)*pi/2; NaN; lat(startpt2:endpt2)];
      lon = [lon(startpt1); lon(startpt1:endpt1); lon(endpt1); NaN; lon(startpt2:endpt2)];
      
   else  %  Patch 2 is traversing.
      
      % Determine closest pole.
      signvec = sign(lat([startpt2 endpt2]));  
      indx = find(signvec == 0);
      if ~isempty(indx);
         signvec(indx) = 1;
      end
      
      % Drop the endpoints to the traversing pole.
      lat = [lat(startpt1:endpt1); NaN; signvec(1)*pi/2; lat(startpt2:endpt2); signvec(2)*pi/2];
      lon = [lon(startpt1:endpt1); NaN; lon(startpt2); lon(startpt2:endpt2); lon(endpt2)];
      
   end
   
end  % end if dropflag loop


%  Remove NaN's that may have been placed at the end of 
%  the vector set.  This will occur if the original data
%  does not contain any NaNs but is required to be dropped
%  to the pole (indx above will be empty).

if isnan(lat(length(lat))) | isnan(lon(length(lon)))
   lat(length(lat)) = [];
   lon(length(lon)) = [];
end


%  Ensure patches are closed by making sure first and last 
%  points of each patch are the same.

%  Reset indx because points may have been added above.
indx = find(isnan(lat) | isnan(lon));

if isempty(indx)
   lastindx = length(lat);
   lat = [lat(lastindx); lat];
   lon = [lon(lastindx); lon];
else
   lastindx  = indx-1;
   firstindx = indx+1;
   lat = [lat(lastindx); lat; lat(firstindx)];
   lon = [lon(lastindx); lon; lon(firstindx)];
end


%*********************************************************************
%*********************************************************************
%*********************************************************************

function [xout,yout,splitout] = EliminateSinglePts(x,y,splitvec)

%  EliminateSinglePoints is a pre-processing of patch data to 
%  eliminate a difficulty with the clipping algorithm.  This
%  function is designed to eliminate single points on one
%  side of a clip boundary (eg:  RLR, LRL, where L = left, R = right).
%  The processing below introduces two points on either side
%  of the boundary so that RLR becomes RRLLLRR and LRL becomes
%  LLRRRLL, which is then handled much better by the clipping
%  algorithm.  Furthermore, this processing deals with situations
%  when a clip occurs at the first or last point in the patch data.
%  Remember, at this point, the patch data has the first point
%  repeated at the end of the data set to enforce closure.  Thus,
%  you can have a clip between the first or last 2 points in the
%  data vector.

%  Note:  Much of this algorithm was developed and tested using
%  the continental United States data from the worldlo workspace,
%  projected with an origin of [0 110 0].  This produces difficult
%  clips on Cape Cod and the coast of Maine.  The edge conditions
%  were developed by permuting the data set so that it began and 
%  ended on clips, particularly the single point clip in the data
%  set.

%  Revised 6/24/97 by T. Debole to include linear interpolation.

epsilon = epsm('radians');

%  Find points where the split is separated by one point.  This
%  indicates LRL or RLR behavior.

indx = find(diff(splitvec) == 1);

%  Test for a clip at the first point of the vector and determine
%  if it is a single clip point.  It is a single clip point only 
%  if there is a clip at the last point of the original data set,
%  i.e. the first and last points are on opposite sides of the clip 
%  boundary.

if any(splitvec == 1) & any(splitvec == length(x)-1)
   indx = [indx; 1];
end

%  Test for a clip at the end of the vector.  Even if there is
%  no clip at the beginning of the set, this condition typically
%  needs some help to be properly handled by the clipping 
%  algorithm.  So, flag it for interpolation.

if any(splitvec == length(x)-1)
   indx = [indx; length(splitvec)-1];
end

%  Test if there is an LRL or RLR condition at the end of the
%  data set.  If there is, only one crossing comes out of the
%  diff calculation.  So, add the one that is missing.

if ~isempty(indx) & any(indx == length(splitvec)-1)
   indx = [indx; length(splitvec)-2];
end

%  Initialize outputs and punt if there are no points to process.

xout = x;  
yout = y;  
splitout = splitvec;

if isempty(indx); 
   return; 
end

%  Order the unique clip points.  Sometimes the last point
%  ends up repeated because of the processing above.

indx = sort(unique(indx));   
indx = [indx(1); indx+1];
indx = indx(find(indx > 0));

%  Loop through each clip point.

for i = length(indx):-1:1
   
   loc = splitvec(indx(i));
   
   % Linearly interpolate a new point on each side of the clip border.
   slope = (y(loc+1) - y(loc)) / (x(loc+1) - x(loc));
   newx = 10*sign(x(loc:loc+1))*epsilon;
   newy = y(loc) + (newx - x(loc)) * slope;
   % newy = y(loc) + slope*newx;
   
   % Add the interpolated points to the data set.  
   xout = [xout(1:loc); newx(:); xout(loc+1:length(xout))];		   
   yout = [yout(1:loc); newy(:); yout(loc+1:length(yout))];		   
   
end

%  Recompute the location of the new split points throughout
%  the patch.

splitout = find(diff(sign(xout)) ~= 0 );
indx = find(abs(xout(splitout) - xout(splitout+1)) <= 1.05*pi);
splitout = splitout(indx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latout,lonout,clipped]=clippatch2(lat,lon)
%CLIPPATCH2 new patch clipping algorithm
%
% [latout,lonout,clipped]=clippatch2(lat,lon) clips (cuts) the patch 
% at the dateline. The input patch (one face only) is provided as vectors of 
% latitude and longitude in units of radians, and has been transformed 
% to center the data on the projection origin. This places the dateline
% at +/- pi/2. The process of clipping cuts patches that don't encompass
% a pole into two pieces at the dateline, and introduces points running 
% up to and around the pole for patches that do encompass a pole. The 
% result is NaN-clipped vectors and a logical flag indicating whether 
% the patch was clipped.
%
% The algorithm first detects whether the patch encompasses the pole by
% counting the dateline crossings. An even number of crossings indicates 
% that the patch only straddles the dateline, but doesn't circle a pole.
% A patch with an odd number of crossings must circle the pole. The segment
% that circles the pole is identified by cutting the patch into line 
% segments, and checking if any segments have a difference in sign of the 
% endpoint. Segments that just touch the dateline from the same direction
% on both sides and don't circle a pole will have a net difference of zero. 
% Those that encompass a pole will have a difference of 2 pi. If a polar
% loop is detected, introduce points along the branch cut up to the pole
% and back down again, in the proper order. The correct pole is identified 
% by assuming that the patch covers less than a hemisphere. Which hemisphere 
% is determined from the geographic mean of the points on the edge of the 
% patch (interpolated to a minumum spacing to allow for non-uniformly spaced 
% points). The end result is the a patch which has an even number of dateline 
% crossings, and can be handled as if it had been provided with no polar 
% loops.
%
% The case with dateline crossings only is handled by again breaking the 
% patch into segments at the dateline crossings. Runs of points along the 
% dateline are introduced between every second pair of dateline crossings
% going along the dateline from north to south. The segments that butt up
% against eatch other are then joined to form fillable patches. The result
% is vectors containing the patch with faces separated by NaNs.

% written by W. Stumpf

% Adjust longitudes to lie in the -pi to pi range

lon=npi2pi(lon,'radians');

% Detect dateline crossings by the change in sign of longitude.
% Indices of all dateline crossing points, and those that
% cross with signs going from positive to negative and negative
% to positive.

cindx= find(diff(sign(lon))~=0 & abs(lon(1:end-1)) > pi/2  & abs(lon(2:end)) > pi/2 );

clipped = 1;
if length(cindx) == 0; 
   latout = lat;
   lonout = lon;
   clipped = 0;
   return; 
   
elseif mod(length(cindx),2)==0 % even number of dateline crossings: no wrap around pole
   
   [latout,lonout] = clipDateline(lat,lon,cindx);
   
else
   
   [latout,lonout] = clipPole(lat,lon,cindx);
   
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latout,lonout] = clipPole(lat,lon,cindx);


% Extract segments between crossings to elements of a cell array.
% This simplifies appending the new points along the dateline that
% are required for properly filled patches.

[latc,lonc] = extractSegments(lat,lon,cindx);

% Interpolate points at the dateline and insert interpolated points 
% between line segments

[latc,lonc,latdateline] = interpolatePoints(lat,lon,latc,lonc,cindx);

% insert points that cut along the dateline, to the pole and back

[latc,lonc]=cutToPole(lat,lon,cindx,latc,lonc,latdateline);

% Convert cell array format back to vectors (not NaN-clipped) 

[latout,lonout] = deal(cat(1,latc{:}), cat(1,lonc{:}));

% Append first point to the polygon to detect the dateline crossing

if ~isequal([latout(1) lonout(1)],[latout(end) lonout(end)])
   latout(end+1)=latout(1);
   lonout(end+1)=lonout(1);
end


% remaining dateline crossings?
cindx= find(diff(sign(lonout))~=0 & abs(lonout(1:end-1)) > pi/2  & abs(lonout(2:end)) > pi/2 );
   
if length(cindx) == 0; return; end
if mod(length(cindx),2) ~= 0; 
   eid = sprintf('%s:%s:invalidPatch', getcomp, mfilename);
   error(eid,'%s','Problem clipping patch'); 
end

[latout,lonout,clippts] = clipDateline(latout,lonout,cindx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latc,lonc]=cutToPole(lat,lon,cindx,latc,lonc,latdateline);
% insert points that cut along the dateline, to the pole and back

% Concatenate starting and ending segments, which are both parts of the
% same face.

[latc,lonc] = closePoly(latc,lonc);

% find patch segment that extends 2pi in longitude
for i=1:length(lonc)
   dlon(i)=sum(diff(lonc{i}));
end

indx=find(abs(dlon) > 0.95*pi);

if length(indx) > 1
   eid = sprintf('%s:%s:invalidLength', getcomp, mfilename);
   error(eid,'%s','Can''t clip patches that spiral or encompass both poles')
end

% determine whether the patch segment is in the northern or southern hemisphere

[latm,lonm]=interpm(latc{indx},lonc{indx},pi/180);
[latm,lonm]=meanm(latm,lonm);

% identify which extreme north or south dateline crossing 
% corresponds to that hemisphere

if latm < 0; 
   [polecrosslat,dindx] = min(latdateline); 
else ; 
   [polecrosslat,dindx] = max(latdateline); 
end

% determine if dateline crossing occurs at the beginning or end
% of the segment. 

latend = latc{indx}(end);
latstart = latc{indx}(1);

% reconstruct cell array segments (throwing away interpolated points)
[latc,lonc] = extractSegments(lat,lon,cindx);

% construct points along the dateline to the pole
latinsert = [	...
	latdateline(dindx) 
	pi/2*sign(latm)	
	pi/2*sign(latm)
	latdateline(dindx) 
];

sgn = sign(lonc{indx}(end));
loninsert = [...
	 pi*sgn
	 pi*sgn
	-pi*sgn
	-pi*sgn
];

% interpolate insertion to 1 degree spacing to follow contours 
% of non-cylindrical projections 

[latinsert,loninsert]=interpm(latinsert,loninsert,pi/180);

% and insert

if latend == polecrosslat
   latc{indx} = [latc{indx}; latinsert];
   lonc{indx} = [lonc{indx}; loninsert];
else
   if indx==1; indx = length(latc); end
   latc{indx} = [latinsert; latc{indx}];
   lonc{indx} = [loninsert; lonc{indx}];
   
end

% Concatenate starting and ending segments, which are both parts of the
% same face.

[latc,lonc] = closePoly(latc,lonc);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latout,lonout,clippts] = clipDateline(lat,lon,cindx);


% Undoing patch clips is regarded as just too hard, so just 
% save the original points.

clippts = [lat lon];

% Extract segments between crossings to elements of a cell array.
% This simplifies appending the new points along the dateline that
% are required for properly filled patches.


[latc,lonc] = extractSegments(lat,lon,cindx);

% Interpolate points at the dateline and insert interpolated points 
% between line segments

[latc,lonc,latdateline] = interpolatePoints(lat,lon,latc,lonc,cindx);

% Add dateline points to close off pieces on either side of dateline

[latc,lonc,indx] = insertDatelinePoints(latc,lonc,latdateline);

% Concatenate starting and ending segments, which are both parts of the
% same face.

[latc,lonc] = closePoly(latc,lonc);

% Chain the polygons to form properly filled patches

[latc,lonc] = connectPoly(latc,lonc,indx);


% Convert cell array format back to NaN-clipped vectors

[latout,lonout] = polyjoin(latc,lonc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latcc,loncc] = connectPoly(latc,lonc,indx);

%connectPoly chains polygon segments in the proper order for filling

% Generate a list of segment numbers as encountered going from 
% top to bottom along the cut (left and right sides). This takes into account
% the fact that branch cut points from upper segments have already been 
% added to the following segment.

leftstart = indx(end:-2:1);

leftend = indx(end-1:-2:1)+1;
leftend(leftend==length(indx)+1)=1; % polygon was already closed

rightstart = indx(end-1:-2:1);

rightend = indx(end:-2:1)+1;
rightend(rightend==length(indx)+1)=1; % polygon was already closed

startindx = [leftstart,rightstart];
endindx   = [leftend, rightend];

% starting with the top segment, search through the starting and ending segment numbers
% to find cases where a starting segment has the same index as the end of the current 
% segment.
k=0;
for i=1:length(startindx)
   if ~isnan(startindx(i))
      k=k+1;
      
      latcc{k}=latc{startindx(i)};
      loncc{k}=lonc{startindx(i)};
      
      lastseg = i;
      startindx(lastseg) = NaN;
      nextindx = find(startindx==endindx(lastseg));
      
      while ~isempty(nextindx)
         
         latcc{k}=[latcc{k}; latc{startindx(nextindx)}];
         loncc{k}=[loncc{k}; lonc{startindx(nextindx)}];
         
         startindx(nextindx) = NaN;
         nextindx = find(startindx==endindx(nextindx));
         
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latc,lonc] = closePoly(latc,lonc);
%closePoly closes polygon by concatenating first and last segment

if length(latc) < 2; return; end

latc{1} = [latc{end}; latc{1}];
lonc{1} = [lonc{end}; lonc{1}];

latc(end) = [];
lonc(end) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latc,lonc,indx] = insertDatelinePoints(latc,lonc,latdateline);

[latdateline,indx] = sort(latdateline);


for i=1:2:length(indx)
      
   % ensure one degree spacing along dateline to follow
   % non-cylindrical projections
   insertlat = [latc{indx(i)}(end); latdateline(i+1)];
   insertlon = [lonc{indx(i)}(end); pi*sign(lonc{indx(i)}(end))];
   [insertlat,insertlon]=interpm(insertlat,insertlon,pi/180);
   insertlat(1) = [];
   insertlon(1) = [];
   
   % insert interpolated points along the dateline between line segments
   
   latc{indx(i)} = [latc{indx(i)}; insertlat ];
   lonc{indx(i)} = [lonc{indx(i)}; insertlon ];
   
   %do it again
   j=indx(i)+1;   
   insertlat = [latdateline(i+1);latc{j}(1)];
   insertlon = [pi*sign(lonc{j}(1));lonc{j}(1)];
   [insertlat,insertlon]=interpm(insertlat,insertlon,pi/180);
   insertlat(end) = [];
   insertlon(end) = [];
   
   latc{j}=[insertlat;latc{j}];
   lonc{j}=[insertlon;lonc{j}];
   
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latc,lonc,latdateline] = interpolatePoints(lat,lon,latc,lonc,cindx);

lon02pi = zero22pi(lon,'radians');

for i=1:length(cindx)
   
   % interpolate points at the dateline

   latdateline(i)=interp1(lon02pi(cindx(i):cindx(i)+1),lat(cindx(i):cindx(i)+1),pi);

	% insert interpolated point between line segments

   latc{i} = [latc{i}; latdateline(i)];
   lonc{i} = [lonc{i}; pi*sign(lonc{i}(end))];
   
   j=i+1;   
   latc{j}=[latdateline(i);latc{j}];
   lonc{j}=[pi*sign(lonc{j}(1));lonc{j}];
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latc,lonc]=extractSegments(lat,lon,cindx)
%extractSegments Extract segments between crossings to elements of a cell array.

[latc{1},lonc{1}] = deal( lat((1:cindx(1))') , lon((1:cindx(1))') );

for i=1:length(cindx)-1
   [latc{i+1},lonc{i+1}] = deal( lat((cindx(i)+1:cindx(i+1))') , lon((cindx(i)+1:cindx(i+1))') );
end

[latc{end+1},lonc{end+1}] = deal( lat((cindx(end)+1:end)') , lon((cindx(end)+1:end)') );

