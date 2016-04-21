function isHG = ishghandle( h )
%ISHGHANDLE True for Handle Graphics object handles.
%   ISHGHANDLE(H) returns an array that contains 1's where the elements
%   of H are valid graphic object handles and 0's where they are not.
%   Differs from ISHANDLE in that Simulink objects handles return false.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:28:50 $

error( nargchk(1,1,nargin) )

%See if it is a handle of some kind
isHG = ishandle(h);
for i = 1:length(h(:))
  if isHG(i)
    isHG(i) = isa(handle(h(i)), 'hg.GObject');
  end
end
