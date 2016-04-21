function isF = isfigure( h )
%ISFIGURE True for Figure handles.
%   ISFIGURE(H) returns an array that contains 1's where the elements
%   of H are valid Figure handles and 0's where they are not.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2003/06/09 05:58:30 $

error( nargchk(1,1,nargin) )

isF = ishghandle(h);

for i = 1:length(h(:))
	if isF(i)
          isF(i) = isa(handle(h(i)),'hg.figure');
	end
end
