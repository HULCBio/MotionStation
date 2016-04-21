function faces = setfaces(x,y)

%SETFACES  Construct the face matrix for a patch, given vertex data
%
%  faces = SETFACES(x,y) will construct the face matrix for a patch,
%  given input vertex data.  The input vertex data are two column
%  vectors, with NaNs separating multiple faces of the patch.  If no
%  NaNs are found, then the face of the patch is defined by all
%  the vertices in the input vector data.  The face matrix and
%  vertex vectors are used to set the Face and Vertices properties
%  of the patch in PATCHM, PATCHESM and SETM.
%
%  See also PATCHM, PATCHESM, SETM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:22:42 $


%  Argument input tests

if nargin ~= 2;  error('Incorrect number of arguments');   end


if all(isnan(x) | isnan(y))     %  If all vertices are NaNs, the
    faces = 1:length(x);        %  patch has been trimmed and will
    return                      %  not be displayed
end

%  Ensure that the input data is in column format.

x = x(:);   y = y(:);

%  Find the individual faces to this patch (Separated by NaNs)
%  Then construct the face matrix.  The face matrix is pre-allocated
%  to the maximum size possible.  In trimmed data sets, some NaNs
%  will be neighboring each other (sequential entries in the vector
%  data) and these NaNs will not produce faces.  These rows of
%  the face matrix will need to be eliminated after construction.
%  (This approach was easier than trying to pre-compute the location
%  of the neighboring NaNs and then keeping all the subsequent
%  bookkeeping straight.  EVB).

indx = find(isnan(x) | isnan(y));


if isempty(indx)
    faces = 1:length(x);    %  All one face
else
	faces = zeros(length(indx),max([diff(indx,[],1)-1;indx(1)]) ); % Preallocate memory
    faces(:) = NaN;       %  Make the whole matrix NaNs
    for i = 1:length(indx)
        if i == 1;      startloc = 1;
             else;      startloc = indx(i-1)+1;
	     end
	     endloc   = indx(i)-1;

         indices = startloc:endloc;   %  Indices will be empty if NaNs are
		                              %  neighboring in the vector data.

         if ~isempty(indices)         %  Neighboring NaNs happen in trimmed data sets
            faces(i,1:length(indices) ) = indices;
		 end
    end
end

