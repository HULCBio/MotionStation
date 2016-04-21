function ofile = fileparamparser(cc,ifile)
%FILEPARAMPARSER Private filename parsing function
%   OFN=FILEPARAMPARSER(CC,IFN) parses the passed filename
%   and does a search for the file in the Code Composer 
%   working directory and then the MATLAB path.   

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.7.4.1 $ $Date: 2003/11/30 23:07:04 $

if ~ischar(ifile),
    error('FILE parameter should be a char array.');
elseif isempty(ifile),
    error('FILE parameter is empty.');
end
ifile = p_deblank(ifile);  % Remove any trailing or leading blanks

[fpath,fname,fext] = fileparts(ifile);
if isempty(fpath),       % No path information at ALL, check Code Composer AND MATLAB path
    ccspath = cc.cd;
    ofile = fullfile(ccspath,ifile);
    if exist(ofile,'file') ~= 2,
        % Not in code composer, try MATLAB path
        ofile = which(ifile);
        if isempty(ofile),
            error('Specified file does not exist on CCS or MATLAB path');
        end
    end    
elseif ~isempty(findstr(ifile,':')) ||strcmp(ifile(1:2),'\\') || strcmp(ifile(1:2),'//'),   % Windows only, Full path given?
    % Networked locations
    ofile = ifile;
    if exist(ofile,'file') ~= 2,
        error('Specified file does not exist on CCS path');
    end

else   % Relative path or .\, check from CCS path ONLY
    ccspath = cc.cd;
    ofile = fullfile(ccspath,ifile);
    if exist(ofile,'file') ~= 2,
        error('Specified file does not exist on CCS path');
    end
end

% [EOF] fileparamparser.m