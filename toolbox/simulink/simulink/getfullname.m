function Name=getfullname(Handle)
%GETFULLNAME Get full path name to block.
%   NAME=GETFULLNAME(HANDLE) returns the full pathname to the block
%   specified by Handle.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

m = size(Handle,1);
n = size(Handle,2);

if (n == 1 & m == 1) | ischar(Handle),
  % input argument is a ref to one block
  PName=get_param(Handle,'Parent');
  Name=strrep(get_param(Handle,'Name'),'/','//');

  if ~isempty(PName),
    Name=[ PName '/'  Name];
  end
else
  Name = cell(m,n);
  if iscell(Handle),
    Handle = reshape([Handle{:}],m,n);
  end
    
  for i=1:m,
    for j=1:n,
      hndl = Handle(i,j);
      PName = get_param(hndl,'Parent');
      baseName = strrep(get_param(hndl,'Name'),'/','//');

      if ~isempty(PName),
	Name(i,j) = {[ PName '/'  baseName]};
      else
	Name(i,j) = {baseName};
      end
    end
  end
end

% end getfullname
