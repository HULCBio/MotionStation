function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.

%       Copyright 1996-2004 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $ $Date: 2004/04/19 01:22:20 $

disp('### Driver Interface Libraries');

% MOD: Updated the include path to reflect the new folder structure.

root = bdroot;
inputblocks = find_system(root,'ReferenceBlock','driver_interface_library/Input Driver');
outputblocks = find_system(root,'ReferenceBlock','driver_interface_library/Output Driver');
blocks = { inputblocks{:} outputblocks{:} };

makeInfo.includePath = { };
makeInfo.sourcePath = { };
for i = 1:length(blocks)
    block = blocks{i};
    if ~isempty(block)
        addheader(get_param(block,'header'));
        addsrc(get_param(block,'src'));
    end
end

    function addheader(header)
        [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(header);
        PATHSTR = expand(PATHSTR);
        paths = makeInfo.includePath;
        if ~isempty(PATHSTR)
            paths = { paths{:} PATHSTR };
            makeInfo.includePath = paths;
        end
    end

    function addsrc(src)
        [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(src);
        PATHSTR = expand(PATHSTR);
        paths = makeInfo.sourcePath;
        if ~isempty(PATHSTR)
            paths = { paths{:} PATHSTR };
            makeInfo.sourcePath = paths;
        end
    end

    function path = expand(path)
        expansions = regexp(path,'(\$[^\\/]*)','tokens');
        for i = 1:length(expansions)
            ex = expansions{i}{1};
            fun = strrep(ex,'$','');
            str = feval(fun);
            path = strrep(path,ex,str);
        end
    end
end