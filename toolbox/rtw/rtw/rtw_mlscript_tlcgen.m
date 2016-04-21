function rtw_mlscript_tlcgen(block,tlcFileName)
%rtw_mlscript_tlcgen: Generate the TLC file for a MATLAB scripting block.
%
%  This internal function is called by Simulink when generating code
%  for the MATLAB scripting block. The MATLAB scriting block is converted
%  to a TLC-file in the subdirectory mlscript. The subdirectory will be
%  created if needed.

%  Copyright 1994-2003 The MathWorks, Inc.
%  $Revision: 1.4.2.2 $

  
  fid = fopen(tlcFileName,'w');

  bname = [get_param(block,'parent'), '/', get_param(block,'name')];
  strrep(bname,sprintf('\n'),' ');
  
  fprintf(fid,['%%%% TLC-file for MATLAB Scripting block:\n%%%% ',bname,'\n']);
  
  seps = findstr(tlcFileName,filesep);
  if isempty(seps)
    seps(1) = 0;
  end
  implementsName = tlcFileName(seps(end)+1:end);
  dot = findstr(implementsName,'.');
  implementsName(dot:end) = [];
  
  fprintf(fid,['\n%%implements "',implementsName,'" "C"\n']);

  CreateTLCFunction('OutputScript',block,fid);
  
  fclose(fid);
  
%endfunction rtw_mlscript_tlcgen


%-------------------------------------------------------------------------------
function CreateTLCFunction(scriptFcnName,block,fid)
  
  script = get_param(block,scriptFcnName);

  tfile=CreateTmpFile(script);
  
  m2tlc(tfile,scriptFcnName);

  tfid = fopen(tfile,'r');
  fwrite(fid,fread(tfid));
  fclose(tfid);

  rtw_delete_file(tfile);
%endfunction CreateTLCFunction


%-------------------------------------------------------------------------------
function tfile = CreateTmpFile(script)
  
  tfile = tempname;
  seps = findstr(tfile,filesep);
  tfile = [tfile(1:seps(end)) 'rtw_' tfile(seps(end)+1:end)];
  while exist( tfile )
    tfile = tempname;
    seps = findstr(tfile,filesep);
    tfile = [tfile(1:seps(end)) 'rtw_' tfile(seps(end)+1:end)];
  end

  tfid = fopen(tfile,'w');
  fwrite(tfid,script);
  fclose(tfid);
  
%endfunction CreateTmpFile


%-------------------------------------------------------------------------------
function m2tlc(tfile,scriptFcnName)
  perlProgram = fullfile(matlabroot,'toolbox','rtw','rtw',...
			 'rtw_mlscript_tlcgen.pl');
  cmd = ['perl ',perlProgram,' ',tfile,' ',scriptFcnName];
  [s,m] = unix(cmd);
  if ~isempty(m)
    disp(cmd);
    disp(m);
  end

%endfunction