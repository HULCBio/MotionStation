function tmp_dir = tempdir
%TEMPDIR Get temporary directory.
%   TEMPDIR returns the name of the temporary directory if one exists
%
%   See also TEMPNAME, FULLFILE.

%   Marc Ullman  2-8-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:29:43 $

persistent temporary;
if isempty(temporary)
comp = [computer '    '];
if strcmp(comp(1:2), 'PC')
    tmp_dir = getenv('TEMP');       % Microsoft's recommended name
    if ( isempty(tmp_dir) )
        tmp_dir = getenv('TMP');    % What everybody else uses
    end
    if ( ~isempty(tmp_dir) )
        % Make sure name ends with a valid path separator
        last_char = tmp_dir(length(tmp_dir));
        if ((last_char ~= '\') & (last_char ~= '/'))
            tmp_dir = [tmp_dir '\'];
        end
    end
else
    % Assume we are on a UNIX system
    tmp_dir = getenv('TMP');
    if isempty(tmp_dir)
        tmp_dir = '/tmp/';
    end
    
end

% Protect against an empty tmp_dir
if isempty(tmp_dir),
  tmp_dir = cd; % Use current directory
else %resolve hard links
    curr_dir = pwd;
    cd(tmp_dir);
    tmp_dir = pwd;
    cd(curr_dir);
    if (tmp_dir(length(tmp_dir)) ~= filesep)
        tmp_dir = [tmp_dir filesep];
    end
end
temporary = tmp_dir;
else
    tmp_dir = temporary;
end
