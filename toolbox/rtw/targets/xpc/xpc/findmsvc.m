function [DIRLOCATION]=findmsvc

% Copyright 2004 The MathWorks, Inc.

lasterr('');
try
    file = fullfile(prefdir,'mexopts.bat');
    fid  = fopen(file,'r');
    if fid < 0
      error('Could not open mexopts.bat: please run mex -setup');
    end
    cont = fread(fid, '*char')';
    fclose(fid);
    % Find lines that contain MSVCDIR & Line breaks
    a=regexp(cont,'MSVCDir');
    b=regexp(cont,[ char(10)]);
    % The first line break that is greater then first MSVCDIR is the one we
    % are looking for
    for i=1:length(b)
        if(b(i)>a(1))
            lineend=b(i);
            break;
        end
    end
    % Now  extract the line
    MSVCLOCATION1=[cont(a(1):lineend)];
    % Parse the location so that we get only the directory and the last '\'.
    % So that we can eliminate \VC98 etc
    c=regexp(MSVCLOCATION1,'=');
    d=regexp(MSVCLOCATION1,'\\');
    DIRLOCATION1=MSVCLOCATION1(c+1:max(d)-1);
    %Hopefully everything worked so far, otherwise we have an error

    if(isempty(DIRLOCATION1))
        error('Mex is not using Microsoft Visual Studio, Please run mex -setup and set your compiler to be Microsoft Visual Studio')
    else
        DIRLOCATION=DIRLOCATION1;
    end
catch
    error(['Unexpected error',lasterr])

end
