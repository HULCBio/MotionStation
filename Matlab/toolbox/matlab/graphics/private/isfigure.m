function isF = isfigure( h )
%ISFIGURE True for Figure handles.
%   ISFIGURE(H) returns an array that contains 1's where the elements
%   of H are valid Figure handles and 0's where they are not.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/04/10 23:29:06 $

error( nargchk(1,1,nargin) )

isF = ishghandle(h);

for i = 1:length(h(:))
	if isF(i)
          isF(i) = isa(handle(h(i)),'hg.figure');
	end
end
