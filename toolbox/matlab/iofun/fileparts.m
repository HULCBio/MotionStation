function [path, fname, extension,version] = fileparts(name)
%FILEPARTS Filename parts.
%   [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(FILE) returns the path, 
%   filename, extension and version for the specified file. 
%   FILEPARTS is platform dependent.
%
%   You can reconstruct the file from the parts using
%      fullfile(pathstr,[name ext versn])
%   
%   See also FULLFILE, PATHSEP, FILESEP.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $ $Date: 2002/06/17 13:27:01 $

path = '';
fname = '';
extension = '';
version = '';

if isempty(name), return, end

% Nothing but a row vector should be operated on.
[m,n] = size(name);
if (m > 1)
  error('Input cannot be a padded string matrix.');
end

if ispc
    orig_name = name;

    % Convert all / to \ on PC
    name = strrep(name,'/','\');
    ind = find(name == filesep | name == ':');
    if isempty(ind)
	fname = name;
    else
        if name(ind(end)) == ':'
            path = orig_name(1:ind(end));
        else 
            path = orig_name(1:ind(end)-1);
        end
        if ~isempty(path) & path(end)==':'
            path = [path '\'];
        end
        fname = name(ind(end)+1:end);
    end
else	% UNIX
    ind = find(name == filesep);
    if isempty(ind)
	fname = name;
    else
        path = name(1:ind(end)-1); 

        % Do not forget to add filesep when in the root filesystem
        if isempty(deblank(path)), path = [path filesep]; end
        fname = name(ind(end)+1:end);
    end
end

if isempty(fname), return, end

% Look for EXTENSION part
ind = max(find(fname == '.'));

if isempty(ind)
    return
else
    extension = fname(ind:end);
    fname(ind:end) = [];
    
    % Make sure name does not have two consecutive dots - m-file's won't reload
    % if strcmp(fname(end), '.') & strcmp(extension(1), '.')
    %    error( [ 'Invalid filename: ' name ] );
    % end
end
