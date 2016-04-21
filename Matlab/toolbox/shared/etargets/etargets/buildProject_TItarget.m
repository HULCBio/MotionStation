function  buildProject_TItarget(ccsObj, modelName)

% $RCSfile: buildProject_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:36:55 $
% Copyright 2001-2003 The MathWorks, Inc.

if exist('cc_build.log','file'),
    delete('cc_build.log');
end
if exist([modelName '.out'],'file'),
    delete([modelName '.out']);
end
if exist([modelName '.map'],'file'),
    delete([modelName '.map']);
end

ccsObj.halt;
disp('### Building Code Composer Studio(R) project...');
try
    ccsObj.build(1000); % compile and link the project file
catch
    error(sprintf(['There was an error building project.\n'...
            'A COFF file may not have been produced.']));
end
disp('### Build complete');

% [EOF] buildProject_TItarget.m
