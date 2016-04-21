function out = xmlstringinput(xString,isFullSearch, returnFile)
%XMLSTRINGINPUT Determine whether a string is a file or URL
%   RESULT = XMLSTRINGINPUT(STRING) will return STRING if
%   it contains "://", indicating that it is a URN.  Otherwise,
%   it will search the path for a file identified by STRING.
%
%   RESULT = XMLSTRINGINPUT(STRING,FULLSEARCH, RETURNFILE) will
%   process STRING to return a RESULT appropriate for passing
%   to an XML process.   STRING can be a URN, full path name,
%   or file name.
%
%   If STRING is a  filename, FULLSEARCH will control how 
%   the full path is built.  If TRUE, the XMLSTRINGINPUT 
%   will search the entire MATLAB path for the filename
%   and return an error if the file can not be found.
%   This is useful for source documents which are assumed
%   to exist.  If FALSE, only the current directory will
%   be searched.  This is useful for result documents which
%   may not exist yet.  FULLSEARCH is TRUE if omitted.
%
%   If RETURNFILE is TRUE, RESULT returns as a java.io.File
%   when STRING is a file.  If RETURNFILE is FALSE,
%   RESULT returns as a URN.  RETURNFILE is TRUE if omitted.
%
%   This utility is used by XSLT, XMLWRITE, and XMLREAD

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:26:21 $


if isempty(xString)
    error('Filename is empty');
elseif ~isempty(findstr(xString,'://'))
    out = xString;
    return;
end

[xPath,xFile,xExt]=fileparts(xString);
if isempty(xPath)
    if nargin<2 | isFullSearch
        out = which(xString);
        if isempty(out)
            error(sprintf('File %s not found',xString));
        end
    else
        out = fullfile(pwd,xString);
    end
else
    out = xString;
    %@NOTE: should we search to see if xString exists when isFullSearch
end

if nargin<3 | returnFile
    out = java.io.File(out);
else
    %Return as a URN
    if strncmp(out,'\\',2)
        % SAXON UNC filepaths need to look like file:///\\\server-name\
        out = ['file:///\',out];
    elseif strncmp(out,'/',1)
        % SAXON UNIX filepaths need to look like file:///root/dir/dir
        out = ['file://',out];
    else
        % DOS filepaths need to look like file:///d:/foo/bar
        out = ['file:///',strrep(out,'\','/')];
    end
end
