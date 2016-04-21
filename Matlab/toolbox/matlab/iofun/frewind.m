function frewind(fid)
%FREWIND Rewind file.
%   FREWIND(FID) sets the file position indicator to the beginning of
%   the file associated with file identifier fid.
%
%   WARNING: Rewinding a fid associated with a tape device may not work
%            even though no error message is generated.
%
%   See also FOPEN, FREAD, FWRITE, FSEEK

%   Martin Knapp-Cordes, 1-30-92, 7-13-92, 11-2-92
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2004/03/26 13:26:26 $

if (nargin ~= 1)
    error ('Wrong number of arguments.')
end

fidvec = fopen('all');
for i = 1:size(fidvec,2)
  if (fid == fidvec(i))
    status = fseek(fid, 0, -1);
    if (status == -1)
        error ('Rewind failed.')
    end
    return
  end
end
error ('Invalid file identifier.')
