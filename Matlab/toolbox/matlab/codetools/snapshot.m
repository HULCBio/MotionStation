function picName = snapshot(filename)
%SNAPSHOT	Run the M-file and save resulting picture.
%   SNAPSHOT(FILENAME)
%   See also STANDARDRPT.

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.4 $  $Date: 2003/12/24 19:12:06 $

fullfilename = which(filename);
if isempty(fullfilename)
    error('MATLAB:snapshot:notfound','Can''t find "%s"',filename)
end
[pathstr,prefix] = fileparts(fullfilename);
baseImageName = fullfile(pathstr,'html',prefix);
message = prepareOutputLocation([baseImageName '.png']);
if ~isempty(message)
    error('MATLAB:snapshot:CannotCreateImage',strrep(message,'\','\\'))
end

imHeight = 64;
pictureName = takepicture(prefix,baseImageName,[],imHeight,[],'print','png');

if nargout > 0
    picName = pictureName;
end
