function delete(h,filename)
%DELETE Delete a file on an FTP server.
%    DELETE(FTP,FILENAME) deletes a file on the server.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:18 $

% Make sure we're still connected.
connect(h)

if any(filename=='*')
    listing = h.jobject.listNames(filename);
    names = cell(size(listing));
    for i = 1:length(listing)
        names{i} = listing(i);
    end
else
    names = {filename};
end

for i = 1:length(names)
    status = h.jobject.deleteFile(names{i});
    if (status == 0)
        error('Could not delete "%s".',char(names(i)));
    end
end
