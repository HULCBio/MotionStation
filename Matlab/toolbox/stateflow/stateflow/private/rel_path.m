function relPath = rel_path(path1, path2),
%
% Compute a relative path (one that takes you from path1 to path2).
%
% Warning this function assumes that path1 and path2 share the same
% ROOT!
%
%
%	Jay R. Torgerson
%	Copyright 1995-2002 The MathWorks, Inc.
%	$Revision: 1.7.2.1 $
	if isempty(path1) | isempty(path2), error('bad args passed to rel_path'); end;
   
    if ispc, 
        path1 = lower(path1);
        path2 = lower(path2);
    end;

    %
    % i) check for equality.
    %
    if isequal(path1, path2), relPath = '.'; return; end;

    % clean up backslashes
    slash = '/';
    path1(path1=='\') = slash;
    path2(path2=='\') = slash;

    %
    % ii) find the common hierarchy
    %
    l1 = length(path1);
    l2 = length(path2);

    minL = min(l1, l2);
    mask = path1(1:minL)==path2(1:minL);

    % 
    % check for complete inclusion of one path in the other
    %
    if all(mask),
        if l1 < l2, % just need to cd down path2
            relPath = [path2((minL+1):end)];
        else,       % need to cd back up
            buff = [path1((minL+1):end)];
            relPath = ['.', slash];
            
            % build UP path
            while ~isempty(buff),
                [junk, buff] = strtok(buff, slash);
                if ~isempty(junk), relPath = [relPath, '..',slash]; end;
            end;
        end;
        return;
    end;

    %
    % or, find overlap
    %
    diffInd = find(~mask);
    
    % if they completely differ, error out. 
    if diffInd < 2, error('paths must share a root!'); end;
    
    overlap = path1(1:(diffInd(1)-1));

    slashes = find(overlap==slash);
    if ~isempty(slashes),
        lastSlashInd = slashes(end);
        overlapPath = overlap(1:lastSlashInd);
    else, 
        error('bad args passed to rel_path');
    end;
    
    % 
    % iii)
    %    now,  cd up from path1 TO the overlapPath,
    %    then, cd down to path2 FROM the overlapPath
    %
    upPath   = rel_path(path1, overlapPath);
    downPath = rel_path(overlapPath, path2);
    
    relPath = [upPath, downPath];


  
    
    



    

