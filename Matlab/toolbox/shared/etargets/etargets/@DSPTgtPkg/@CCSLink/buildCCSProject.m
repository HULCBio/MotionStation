function  buildCCSProject (h, ccsObj, modelName)

% $RCSfile: buildCCSProject.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:27 $
% Copyright 2003-2004 The MathWorks, Inc.

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
disp('### Building Code Composer Studio(tm) project...');
try
     ccsObj.build(1000); % compile and link the project file
catch
     error(sprintf(['There was an error building project.\n'...
             'A COFF file may not have been produced.']));
end
disp('### Build complete');

% [EOF] buildCCSProject.m
