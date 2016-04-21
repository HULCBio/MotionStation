function tline = fgetl(fid)
%FGETL Read line from file, discard newline character.
%   TLINE = FGETL(FID) returns the next line of a file associated with file
%   identifier FID as a MATLAB string. The line terminator is NOT
%   included. Use FGETS to get the next line with the line terminator
%   INCLUDED. If just an end-of-file is encountered then -1 is returned.
%
%   FGETL is intended for use with text files only.  Given a binary file
%   with no newline characters, FGETL may take a long time to execute.
%
%   Example
%       fid=fopen('fgetl.m');
%       while 1
%           tline = fgetl(fid);
%           if ~ischar(tline), break, end
%           disp(tline)
%       end
%       fclose(fid);
%
%   See also FGETS, FOPEN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:29:22 $
%

try
    [tline,lt] = fgets(fid);
    tline = tline(1:end-length(lt));
    if isempty(tline)
        tline = '';
    end

catch
    if nargin ~= 1
        error (nargchk(1,1,nargin,'struct'))
    end
    if isempty(fopen(fid))
        error ('MATLAB:fgetl:InvalidFID','Invalid file identifier.')
    end
    rethrow(lasterror)
end
