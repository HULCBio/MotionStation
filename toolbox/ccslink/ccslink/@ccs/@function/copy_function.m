function copy_function(ff,resp)
%   Private. Copies over FF properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2003/11/30 23:08:17 $

% public properties

resp.name                         = ff.name;
resp.filename                     = ff.filename;
resp.address                      = ff.address;
resp.type                         = ff.type;
resp.variables                    = ff.variables;
resp.inputnames                   = ff.inputnames;
resp.inputvars                    = ff.inputvars;
resp.outputvar                    = ff.outputvar;
resp.outputvar                    = ff.outputvar;
resp.link                         = ff.link;
resp.timeout                      = ff.timeout;
resp.userdata                     = ff.userdata;

% private properties

resp.procsubfamily      = ff.procsubfamily;
resp.funcdecl           = ff.funcdecl;
resp.islibfunc          = ff.islibfunc;
resp.savedregsvalue     = ff.savedregsvalue;
resp.localvars          = ff.localvars;
resp.uclass             = ff.uclass;
resp.input_sp_offset    = ff.input_sp_offset;
resp.input_fp_offset    = ff.input_fp_offset;
resp.fp_address         = ff.fp_address;
resp.return_address     = ff.return_address;
resp.current_sp_offset  = ff.current_sp_offset;
resp.savedreg_status    = ff.savedreg_status;
resp.stackallocation    = ff.stackallocation;
resp.objectdata         = ff.objectdata;

SetupSavedRegisterList(resp);
CopySaveRegList(resp,ff);

%------------------------------
function CopySaveRegList(resp,ff)

addregister(resp,ff.savedregs);
for i=1:length(resp.savedregs)
    resp.savedregsvalue(i) = ff.savedregsvalue(i);
end

%--------------------------------------
function SetupSavedRegisterList(ff)

ff.savedregs      = p_saved_register_list(ff,ff.procsubfamily);
ff.savedregsvalue = zeros(1,length(ff.savedregs));

% [EOF] copy_function.m