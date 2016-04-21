function varargout = sfclose( sfIds )
%SFCLOSE Closes a Stateflow diagram.
%        SFCLOSE closes the current Stateflow diagram.
%        SFCLOSE( 'CHARTNAME' ) closes the specified Stateflow diagram.
%        SFCLOSE( HANDLE ) closes the Stateflow diagram specified by its handle.
%        SFCLOSE( 'ALL' ) closes all open and/or iconified Stateflow diagrams.
%
%        See also STATEFLOW, SFNEW, SFSAVE, SFPRINT, SFEXIT, SFHELP.

%	E. Mehran Mestchian
%	Jay R. Torgerson
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.14.2.2 $  $Date: 2004/04/15 01:01:35 $

error(nargchk(0,1,nargin));
error(nargchk(0,1,nargout));
cancelFlag = 0;
if (nargout > 0), varargout{1} = cancelFlag; end;

switch nargin
case 0, 
  sfIds = currentchart; 
  if (sfIds == 0), return; end;
case 1, % Close a specific editor
  if ischar(sfIds)
    if strcmp(sfIds,'all'), 
      sfIds = sf('get','all','chart.id');
    else, 
      sfIds = sf('find','all','chart.name',sfIds);
    end
  else
    sfIds(sf('ishandle',sfIds)==0) = [];
    sfIds = sf('get',sfIds,'chart.id');
  end
otherwise
  error( nargchk(0,1,nargin));
end

sf('set',sfIds,'.visible',0);

