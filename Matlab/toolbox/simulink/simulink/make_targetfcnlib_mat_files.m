function make_target_fcnlib_mat_files()
%ake_target_fcnlib_mat_files - Utility that creates TFL .mat files
%  
%  This function creates the TargetFcnLib .mat files that ship in
%  the toolbox/simulink/simulink directory: 
%  
%  toolbox/simulink/simulink/ansi_tfl_tmw.mat
%  toolbox/simulink/simulink/iso_tfl_tmw.mat
%  toolbox/simulink/simulink/gnu_tfl_tmw.mat
%  
%  These files specify how functions are to be implemented on a target
%  by instantiating the UDD classes Simulink.RtwFcnLib, Simulink.RtwFcnEntry, 
%  and Simulink.RtwFcnImplementation.
%  
%  The following M files control how each .mat file is created:
%  
%  make_rt_math_lib.m  creates  ansi_tfl_tmw.mat (was iso_c_tmw.mat)
%  make_ert_math_lib.m creates  iso_tfl_tmw.mat (was ert_math_tmw.mat)
%                               and uses make_rt_math_lib.m
%  make_gnu_ert_math_lib creates gnu_tfl_tmw.mat (was ert_gnu_math_tmw.mat)
%                               and uses make_ert_math_lib.m
%  
%  With this structure changes to make_ansi_tfl.m may cause all three .mat 
%  files to change.
%  
%  Run this file from its current directory to:
%  
%  1. delete the existing .mat files.
%  2. regenerate each .mat file and install in the correct location
%  

% Copyright 2003 The MathWorks, Inc.

% $Revision $
% $Date: 2004/04/15 00:46:27 $

currDir = pwd;
addpath(currDir);

try
    cd(fullfile(matlabroot,'toolbox','simulink','simulink'));

    if (~force_file_delete('ansi_tfl_tmw.mat')) error('Creating file'); end
    h = make_ansi_tfl;
    h.writeLib;
    disp('Created ansi_tfl_tmw.mat')
    % make_read_only('ansi_tfl_tmw.mat');   % Uncomment if this is part of Bat
    
    if (~force_file_delete('iso_tfl_tmw.mat')) error('Creating file'); end
    h = make_iso_tfl;
    h.writeLib;
    disp('Created iso_tfl_tmw.mat')
    % make_read_only('iso_tfl_tmw.mat'); % Uncomment if this is part of Bat
    
    if (~force_file_delete('gnu_tfl_tmw.mat')) error('Creating file'); end
    h = make_gnu_tfl;
    h.writeLib;
    disp('Created gnu_tfl_tmw.mat');
    % make_read_only('gnu_tfl_tmw.mat'); % Uncomment if this is part of Bat
catch
    disp(['Error creating math library files: ' lasterr]);
    error('ERROR: cannot make one or more Target Function Library MAT files');
end

cd(currDir)
rmpath(currDir)


function ok = force_file_delete(fileName)

    if exist(fullfile(pwd,fileName))~=2
        ok = 1;
        return;
    end
    
    try
        dtxt = evalc(['delete(''' fileName ''');']);
        %delete(fileName);
        if exist(fullfile(pwd,fileName))==2, 
             error('could not delete'); 
        end
        ok = 1;
    catch
        try,
            if ispc,
                dos(['attrib -r ' fileName]);
            else
                unix(['chmod +w ' fileName]);
            end
            dtxt = evalc(['delete(''' fileName ''');']);
            %delete(fileName);
            if exist(fullfile(pwd,fileName))==2, 
              error('could not delete'); 
            end
            ok = 1;
        catch
            disp(['Could not delete ' fileName]);
            ok = 0;
        end
    end
    
function make_read_only(fileName)

    try,
        if ispc,
            dos(['attrib +r ' fileName]);
        else
            unix(['chmod -w ' fileName]);
        end
    catch,
    end
          