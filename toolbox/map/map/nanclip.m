function mat = nanclip(datain,pendowncmd)

%NANCLIP  Clips vector data with NaNs at specified pen-down locations
%
%  mat = NANCLIP(datain) creates NaN clipped vectors from pen-down
%  identified vectors.  The first column in datain must contain the
%  pen-down commands identifying the start of a new vector.  The output
%  argument, mat, will have n-1 columns, where n is the number of
%  columns of datain.  The assumed pen down command is a -1 at the
%  proper location in the first column of the input matrix.
%
%  mat = NANCLIP(datain,pendowncmd) uses the specified input scalar
%  pendowncmd.
%
%  See also SPCREAD, DLMREAD

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.10.4.1 $ $Date: 2003/08/01 18:17:17 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
	 error('Incorrect number of arguments')
elseif nargin == 1
     pendowncmd = -1;
end

%  Input dimension tests

if ndims(datain) > 2
    error('Input matrix can not have pages')
end


%  Find the pen-down locations and compute each segment's
%  starting and ending indices

indx = find(datain(:,1) == pendowncmd);
if isempty(indx);    indx = 1;  end
endpts   = [indx(2:length(indx))-1; size(datain,1)];
startpts = indx;

%  Initialize the output data matrix as all NaNs.  The
%  number entries will be replaced later.

cols = size(datain,2);
mat = NaN;
mat = mat ( ones( size(datain,1)+length(indx), cols-1) );


% Construct the index vector from each start point to end point

offset = (0:length(indx)-1)';    %  Offset for each segment break
startpts = startpts+offset;      %  Segment start row location in mat output
endpts   = endpts+offset;        %  Segment end row location in mat output

rowindx = [];                    %  Fill indices between each start and end index
for i = 1:length(indx)
     rowindx = [rowindx;  (startpts(i) : endpts(i) )' ];
end

%  Set the Non-NaN entries in the mat output matrix

mat(rowindx,:) = datain(:,2:cols);
