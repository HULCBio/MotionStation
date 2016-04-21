function [tmf, compLoc] = xpc_default_tmf
%XPC_DEFAULT_TMF Returns the "default" template makefile for use with xpctarget.tlc
%

%       Copyright 1996-2004 The MathWorks, Inc.
%       $Revision: 1.4.4.2 $ $Date: 2004/03/30 13:14:24 $

compiler    = getxpcenv('CCompiler', 'CompilerPath');
compLoc     = compiler{2};
compiler(2) = [];

intelcompiler = getenv('ICL');

if strcmp(compiler,'Watcom')
  suffix = '_watc.tmf';
end
if strcmp(compiler,'VisualC')
  if exist(fullfile(compLoc, 'IA32'))
    if ~strcmpi(getenv('ICL'), compLoc)
      error(['Set the environment variable ICL to point to the Intel ' ...
             'compiler root directory']);
    end
    suffix  = '_intel.tmf';
    compLoc = findmsvc;
  else
    suffix = '_vc.tmf';
  end
end

tmf = ['xpc', suffix];


%end xpc_default_tmf.m