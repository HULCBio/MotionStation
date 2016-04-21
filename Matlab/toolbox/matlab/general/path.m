function p = path(path1,path2)
%PATH Get/set search path.
%   PATH, by itself, prettyprints MATLAB's current search path. The initial
%   search path list is set by PATHDEF, and is perhaps individualized by
%   STARTUP.
%
%   P = PATH returns a string containing the path in P. PATH(P) changes the
%   path to P.  PATH(PATH) refreshes MATLAB's view of the directories on
%   the path, ensuring that any changes to non-toolbox directories are
%   visible.
%
%   PATH(P1,P2) changes the path to the concatenation of the two path
%   strings P1 and P2.  Thus PATH(PATH,P) appends a new directory to the
%   current path and PATH(P,PATH) prepends a new directory.  If   P1 or P2
%   are already on the path, they are not added.
%
%   For example, the following statements add another directory to MATLAB's
%   search path on various operating systems:
%
%     Unix:     path(path,'/home/myfriend/goodstuff')
%     Windows:  path(path,'c:\tools\goodstuff')
%
%   See also WHAT, CD, DIR, ADDPATH, RMPATH, GENPATH, PATHTOOL, SAVEPATH, REHASH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.24.4.4 $  $Date: 2004/02/07 19:12:21 $

if nargin == 0  % Pretty-print
    if nargout == 0
        matlabpath
    end
elseif nargin == 1
    if ~ischar(path1)
        error('Arguments must be strings.')
    end
    matlabpath(path1)
elseif nargin == 2
    if ~ischar(path1) || ~ischar(path2)
        error('Arguments must be strings.')
    end
    
    % If path1 is contained in path2 or vice versa, don't add it
    pp = matlabpath;
    
    % Windows is case-insensitive
    % Use "Cased" variables for comparisons, 
    %   but do real work on path1 and path2
	% Define FILESEP and PATHSEP, since these are not built-in
	% and PATH might be called with an empty MATLAB path
    if strncmp(computer,'PC',2),
		fs = '\';
		ps = ';';
        path1 = strrep(path1,'/','\');
        path2 = strrep(path2,'/','\');
        path1Cased  = lower(path1);
        path2Cased  = lower(path2);
        ppCased = lower(pp);
	else
	    fs = '/';
		ps = ':';
        path1Cased = path1;
        path2Cased = path2;
        ppCased = pp;
    end
    
    if isempty(path1Cased)
        if ~strcmp(ppCased,path2Cased), matlabpath(path2), end
    elseif isempty(path2Cased)
        if ~strcmp(ppCased,path1Cased), matlabpath(path1), end
    else
        % Check for special cases path(path1,path) or path(path,path2)
        if strcmp(ppCased,path1Cased), append = 1; else append = 0; end
        
        % Add path separator to path1 and path2
        if ~isempty(path1Cased) && path1Cased(end)~=ps, path1 = [path1 ps]; end
        if ~isempty(path2Cased) && path2Cased(end)~=ps, path2 = [path2 ps]; end

        cPath1 = parsedirs(path1);
        cPath2 = parsedirs(path2);
        
        % Use "Cased" variables for comparisons, 
        %   but do real work on cPath1 and cPath2
        if strncmp(computer,'PC',2)
            cPath1Cased  = lower(cPath1);
            cPath2Cased  = lower(cPath2);
        else
            cPath1Cased = cPath1;
            cPath2Cased = cPath2;
        end
        
        % Loop through path to see if we're adding existing paths
        % If so, move them to the beginning or end as specified
        % On Windows, search without case, but use actual inputs when
        % calling MATLABPATH to preserve case
        pmatch = false(size(cPath1));
        if append
			pmatch = false(size(cPath1));
            for n=1:length(cPath2Cased)
				pmatch = pmatch | strcmp(cPath2Cased{n},cPath1Cased);
            end
            cPath1(pmatch) = [];
		else
			pmatch = false(size(cPath2));
            for n=1:length(cPath1Cased)
				pmatch = pmatch | strcmp(cPath1Cased{n},cPath2Cased);
            end
            cPath2(pmatch) = [];
        end

        if isempty(cPath2),
            matlabpath(path1);
        elseif isempty(cPath1)
            matlabpath(path2);
        else
            matlabpath([cPath1{:} cPath2{:}]);
        end
    end
end
        
if nargout==1, p = matlabpath; end
