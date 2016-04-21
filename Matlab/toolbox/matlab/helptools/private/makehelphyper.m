function hyperHelp = makehelphyper(actionName, pathname, fcnName, helpStr)
%MAKEHELPHYPER Reformat help output so that the content has hyperlinks

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/06 21:53:21 $

itemLoc = which(fcnName);
if (strcmp(itemLoc,'built-in'))
    itemLoc = which([fcnName '.m']);
end
% Isolate the function name in case a full pathname was passed in
[unused fcnName unused unused] = fileparts(fcnName);
% Is this topic a function?
itemIsFunction = length(itemLoc);

% Make "see also" references act as hot links
CR = sprintf('\n');
seeAlso = sprintf('See also');
lengthSeeAlso = length(seeAlso);
xrefStart = findstr(helpStr, sprintf('See also'));
if length(xrefStart) > 0
    nameChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/';
    delimChars = [ '., ' CR ];
    % Determine start and end of "see also" potion of the help output
    pieceStr = helpStr(xrefStart(1)+lengthSeeAlso : length(helpStr));
    periodPos = findstr(pieceStr, '.');
    notePos = min([findstr(pieceStr, sprintf('Overloaded')) findstr(lower(pieceStr), sprintf('note:'))]);
    if isempty(periodPos) && isempty(notePos)
        xrefEnd = length(helpStr);
        trailerStr = '';
    elseif isempty(notePos) || (~isempty(periodPos) && periodPos(1)<notePos(1))
        xrefEnd = xrefStart(1)+lengthSeeAlso + periodPos(1) - 1;
        trailerStr = pieceStr(periodPos(1)+1:length(pieceStr));
    else
        xrefEnd = xrefStart(1)+lengthSeeAlso + notePos(1) - 1;
        trailerStr = pieceStr(notePos(1):length(pieceStr));
    end

    % Parse the "See Also" portion of help output to isolate function names.
    seealsoStr = '';
    word = '';
    for chx = xrefStart(1)+lengthSeeAlso : xrefEnd
        if length(findstr(nameChars, helpStr(chx))) == 1
            word = [ word helpStr(chx)];
        elseif (length(findstr(delimChars, helpStr(chx))) == 1)
            if length(word) > 0
                % This word appears to be a function name.
                % Make link in corresponding "see also" string.
                fname = lower(word);
                seealsoStr = [seealsoStr '<a href="matlab:' actionName ' ' fname '">' fname '</a>'];
            end
            seealsoStr = [seealsoStr helpStr(chx)];
            word = '';
        else
            seealsoStr = [seealsoStr word helpStr(chx)];
            word = '';
        end
    end
    % Replace "See Also" section with modified string (with links)
    helpStr = [helpStr(1:xrefStart(1)+lengthSeeAlso -1) seealsoStr trailerStr];
end

% If there is a list of overloaded methods, make these act as links.
overloadPos =  findstr(helpStr, 'Overloaded');
if strcmp(actionName,'doc') == 1
    textToFind = ' doc ';
    len = 5;
else
    textToFind = ' help ';
    len = 6;
end

if length(overloadPos) > 0
    pieceStr = helpStr(overloadPos(1) : length(helpStr));
    % Parse the "Overload methods" section to isolate strings of the form "help DIRNAME/METHOD"
    overloadStr = '';
    linebrkPos = find(pieceStr == CR);
    lineStrt = 1;
    for lx = 1 : length(linebrkPos)
        lineEnd = linebrkPos(lx);
        curLine = pieceStr(lineStrt : lineEnd);
        methodStartPos = findstr(curLine, textToFind);
        methodEndPos = [length(curLine) - 2];
        if (length(methodStartPos) > 0 ) && (length(methodEndPos) > 0 )
            linkTag = ['<a href="matlab:' actionName ' ' curLine(methodStartPos(1)+len:methodEndPos(1)+1) '">'];
            overloadStr = [overloadStr curLine(1:methodStartPos(1)) linkTag curLine(methodStartPos(1)+1:methodEndPos(1)+1) '</a>' curLine(methodEndPos(1)+2:length(curLine))];
        else
            overloadStr = [overloadStr curLine];
        end
        lineStrt = lineEnd + 1;
    end
    % Replace "Overloaded methods" section with modified string (with links)
    helpStr = [helpStr(1:overloadPos(1)-1) overloadStr];
end


% If this topic is not a function description, then it is likely a Contents.m file.
% Scan it for function lists, and modify function names to act as active links.
if (itemIsFunction == 0) || (strcmpi(fcnName, 'Contents')) || (length(findstr(helpStr,'is both a directory and a function'))) || (strcmp(fcnName,'simulink')) || (strcmp(fcnName,'debug'))
    fcnPath = '';
    if isempty(pathname) && ~isempty(fcnName)
        % We need the pathname to be the name of the dictory, and the
        % fcnName to be 'Contents'.
        pathname = fcnName;
        fcnName = 'Contents';
    end 
    if strcmpi(fcnName, 'Contents') && ~isempty(pathname)
        [fcnPath unused unused] = fileparts(which([pathname filesep fcnName]));
        if strncmp(matlabroot, fcnPath, length(matlabroot)) == 1
            % if under matlabroot, find the toplevel product directory to
            % use for comparison later.
            tbxPath = fullfile(matlabroot, 'toolbox');
            
            % get the portion of the path after "toolbox"
            postTbxPath = fcnPath(length(tbxPath)+2:end);
            
            % final path for comparison is mlroot/toolbox/<dirname>...
            fcnPath = fcnPath(1:length(tbxPath)+findstr(postTbxPath, filesep));
        end
    end
    TAB = sprintf('\t');
    helpStr = strrep(helpStr, TAB, ' ');
    modHelpStr = '';
    linebrkPos = find(helpStr == CR);
    lineStrt = 1;
    for lx = 1 : length(linebrkPos)
        lineEnd = linebrkPos(lx);
        curLine = helpStr(lineStrt : lineEnd);
        hyphPos = findstr(curLine, ' - ');
        if any(hyphPos)
            nonblankPos = find(curLine ~= ' ');
            if curLine(nonblankPos(1)) == '-'
                modHelpStr = [modHelpStr curLine];
            else
                for i = nonblankPos(1):hyphPos(1)
                    if (curLine(i) == ' ') || (curLine(i) == ','), break, end;
                end
                fname = curLine(nonblankPos(1):i-1);
                remainder = curLine(i:end);
                try
                    % If there is any help for this name, insert a link for it.
                    % However, avoid the expensive call to "help" by using "exist"
                    % to first test for mfiles, builtins, and directories.
                    fnameType = exist(fname);
                    if (fnameType == 2) || (fnameType == 7) || (fnameType == 5) || (fnameType == 8) || (any(builtin('helpfunc',fname)))
                        if ~isempty(fcnPath) && strncmp(fcnPath, which(fname), length(fcnPath)) == 0
                            % this is likely a shadowed function
                            modHelpStr = [modHelpStr curLine];                            
                        elseif strcmp(fname,'Readme')
                            modHelpStr = [modHelpStr curLine(1:nonblankPos(1)-1) '<a href="' 'matlab:' actionName ' ' topic '/Readme">' fname '</a>' remainder];
                        elseif remainder(1) == ','
                            % Sometimes there are two names separated by a comma.
                            [fname2, remainder2] = strtok(remainder(3:end));
                            modHelpStr = [modHelpStr curLine(1:nonblankPos(1)-1) '<a href="' 'matlab:' actionName ' ' fname '">' fname '</a>, ' '<a href="' 'matlab:help ' fname2 '">' fname2 '</a>' remainder2];
                        else
                            modHelpStr = [modHelpStr curLine(1:nonblankPos(1)-1) '<a href="' 'matlab:' actionName ' ' fname '">' fname '</a>' remainder];
                        end
                    else
                        modHelpStr = [modHelpStr curLine];
                    end
                catch
                    % Just in case an error occurred during the helpfunc call, don't try to
                    % hyperlink anything.
                    modHelpStr = [modHelpStr curLine];
                end
            end
        else
            modHelpStr = [modHelpStr curLine];
        end
        lineStrt = lineEnd + 1;
    end
    helpStr = modHelpStr;
end

hyperHelp = helpStr;



