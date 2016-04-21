function isSL = isslhandle( h )
%ISSLHANDLE True for Simulink object handles for models or subsystem.
%   ISSLHANDLE(H) returns an array that contains 1's where the elements of
%   H are valid printable Simulink object handles and 0's where they are not.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 17:09:11 $

error( nargchk(1,1,nargin) )

pendingError = lasterr;
wasError = 0;

%See if it is a handle of some kind
isSL = ishandle(h);
for i = 1:length(h(:))
  if isSL(i)
    %If can not GET the Type of the object then it is not an HG object.
    dberror = disabledberror;
    try
      t = get_param(h(i),'type');
      isSL(i) = strcmp( 'block_diagram', get_param( h(i), 'type' ) );
      if ~isSL(i)
	isSL(i) = strcmp( 'SubSystem', get_param( h(i), 'blocktype' ) );
      end
    catch
      isSL(i) = logical(0);
      wasError = 1;
    end
    enabledberror(dberror);
  end
end

%Do not change the current error that may be reported by user of this function.
if wasError
	lasterr( pendingError )
end

