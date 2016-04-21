function saveasmmat( h, name )
%SAVEASM Save Figure as an M-file and MAT-file for property values

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 17:04:52 $

% remove ext from filename so appropriate M-file / MAT-file pairs get generated
[path, name, ext] = fileparts(name);

if ~isempty(find(name == '.'))
    error(['Invalid m-file name: ' filename ', . (dot) is not valid filename character.']);
end

hardcopy(h, '-dmfile', fullfile(path, name));
