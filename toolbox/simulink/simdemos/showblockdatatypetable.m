function showblockdatatypetable(Action)
%SHOWBLOCKDATATYPETABLE  Launches html page in help browser to show
%   data type & production intent information for library blocks.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/18 14:58:15 $

if nargin == 0
  Action = 'LaunchHTML';
end

switch Action
case 'LaunchHTML'
  fileName = 'blockdatatypetable.html';
  fullPathToFile = which(fileName);
  if isempty(fullPathToFile)
    errordlg(['File ''', fileName, ''' not found.']);
  else
    status = web(['file:////' fullPathToFile]);
    switch status
    case 1
      errordlg('Web browser not found')
    case 2
      errordlg('Web browser cannot be launched')
    otherwise
      % No action, web browser launched successfully.
    end
  end
otherwise
  warning(['Unrecognized action: ', Action]);
end
