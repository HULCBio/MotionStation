function chname = idchnona(Names)
%IDCHNONA Checks for forbidden channel names
%
%   CHNAME = IDCHNONA(Name) returns empty if Name is an allowed channel
%   name. Otherwise CHNAME is a forbidden name. The check is made
%   for case-insensitive names.
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/08/03 14:23:47 $

chname = [];
if ~iscell(Names),Names={Names};end

PropList = {'measured','noise'};

% Set number of characters used for name comparison
for kk = 1:length(Names)
    Name = Names{kk};
    if strcmp(lower(Name),'all')
        error('Do not use ''all'' for channel names.')
    end
    nchars = length(Name);
   
    imatch = find(strncmpi(Name,PropList,nchars));
    if ~isempty(imatch)
        chname=PropList{imatch};
    end
    
end


 