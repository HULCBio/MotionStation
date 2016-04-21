function funcdecl = p_extract_funcdecl(cc,filename,linenum)
% (Private) Extracts function declaration from given file and line number.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/01 16:02:38 $

error(nargchk(3,3,nargin));
if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP handle.');
end
funcdecl=[];
if CannotProceed(filename,linenum) % because of insufficient info
    return;
end

try
    % Look for function declaration
    funcdecl = callSwitchyard(cc.ccsversion,[65,cc.boardnum,cc.procnum,cc.timeout,cc.eventwaitms],filename,linenum); % call switchyard
    funcdecl = RemoveSpaces(funcdecl);
catch
	% Set cursor to begining of function
	if ~isempty(filename)
        % get full filename (with path)
        [filename,pjtnum] = GetFullFilename(cc,filename);
		if pjtnum==0 || (pjtnum~=0 && isempty(filename))
            try
                error(generateccsmsgid('FuncDeclNotLocated'),'The source file cannot be located, the function declaration therefore cannot be extracted.');
            end
        else
            % open file and set cursor to specified line
            funcdecl = callSwitchyard(cc.ccsversion,[65,cc.boardnum,cc.procnum,cc.timeout,cc.eventwaitms],filename,linenum); % call switchyard
            funcdecl = RemoveSpaces(funcdecl);
        end
	else
        try
            error(generateccsmsgid('FuncDeclNotLocated'),['GOTO: Unable to locate position of function declaration in any source file.']);
        end
	end
end

%----------------------------------------------
function [fullfilename,pjtnum] = GetFullFilename(cc,filename)
% Find full filename, line position & src id
    fullfilename = [];
    pjtnum = 0;
prjinfo = list(cc,'project');
pjtnum = length(prjinfo);
if pjtnum==0
    return;
end
for j=1:pjtnum
for i=1:length(prjinfo(j).srcfiles)
    [pathstr,name,ext,ver] = fileparts(prjinfo(j).srcfiles(i).name);
    if strcmpi(filename,[name,ext])
        fullfilename = prjinfo(j).srcfiles(i).name;
        break;
    end
end
if ~isempty(fullfilename)
    break;
end
end

%---------------------------------
function funcdecl = RemoveSpaces(funcdecl)
p_funcdecl = '';
while ~strcmp(funcdecl,p_funcdecl) 
    p_funcdecl = funcdecl;
    funcdecl = strrep(p_funcdecl,'  ',' ');
end

%---------------------------------
function resp = CannotProceed(filename,linenum)
if isempty(filename) || isempty(linenum)
    resp = 1;
else
    resp = 0;
end

% [EOF] goto.m