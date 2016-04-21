function isHG = ishghandle( h )
%ISHGHANDLE True for Handle Graphics object handles.
%   ISHGHANDLE(H) returns an array that contains 1's where the elements
%   of H are valid graphic object handles and 0's where they are not.
%   Differs from ISHANDLE in that Simulink objects handles return false.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/04/11 18:28:21 $

error( nargchk(1,1,nargin) )

pendingError = lasterr;
wasError = 0;

%See if it is a handle of some kind
isHG = ishandle(h);
for i = 1:length(h(:))
  if isHG(i)
    %If can not GET the Type of the object then it is not an HG object.
    try
      t = isa(handle(h(i)), 'hg.GObject');
      isHG(i) = logical(1);
    catch
      isHG(i) = logical(0);
      wasError = 1;
    end
  end
end

%Do not change the current error that may be reported by user of this function.
if wasError
  lasterr( pendingError )
end

