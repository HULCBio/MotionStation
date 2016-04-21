function generate_CDB_TItarget (target_state, modelInfo)

% Generate DSP/BIOS configuration (.cdb) file based on the Java Script
% file selected according to the memory map used
% Note: .cdb file gets generated in the CCS_Obj's current working folder 
% under the name <model>.cdb

% $RCSfile: generate_CDB_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:14 $
% Copyright 2001-2003 The MathWorks, Inc.

% change to the project folder, saving current working folder first
cwdccsobj = target_state.ccsObj.cd;
target_state.ccsObj.cd(pwd);

% Run Java Script through the TI's TCONF utility 
disp ('### Generating the DSP/BIOS configuration file ...');

dst1 = [pwd '\' modelInfo.name '.tcf'];
dst2 = strrep (dst1,'\','/');

% if call to TCONF errors it may be because TCONF patch was applied to
% older version of CCS
try
    st = dos([strrep(target_state.ccsObj.ccsappexe, '\cc\bin\','') '\bin\utilities\tconf\tconf.exe ' dst1]);
catch
    disp(lasterr)
    error('Error invoking TCONF.');
end
if st,
    error('Error returned from TCONF.');
end
% restore the working folder
target_state.ccsObj.cd(cwdccsobj);

% [EOF] generate_CDB_TItarget.m
