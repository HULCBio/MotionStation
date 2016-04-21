function tgt = rtw_rsim_mdlref_compatibility(iTargetType)
% RSIM_RTW_MDLREF_COMPATIBILITY Specifies model reference compatibility of
%                              properties in the RSIM RTW-Target component.

% Copyright 2003 The MathWorks, Inc.
 
  % See rtw_mdlref_compatibility.m in this directory for exaplaination of
  % the syntax in the cell arrays below.
  
  % RSIM specific RTW->Target Component

  tgt.Name                        = {0, 'invalid', {'Target'}};
  tgt.Description                 = {2, ''};
  tgt.Components                  = {0, 'invalid', {}};
  tgt.GenerateFullHeader          = {2, ''};
  tgt.IsPILTarget                 = {2, ''};
  tgt.IsERTTarget                = {2, ''};
  tgt.ModelReferenceCompliant     = {0, 'invalid', {'on'}};
  tgt.RSIM_SOLVER_SELECTION       = {2, ''};
  tgt.PCMatlabRoot                = {2, ''};
  tgt.ExtMode                     = {1, 'not supported', {'off'}};
  tgt.ExtModeTransport            = {2, ''};
  tgt.ExtModeStaticAlloc          = {2, ''};
  tgt.ExtModeStaticAllocSize      = {2, ''};
  tgt.ExtModeTesting              = {2, ''};
  tgt.ExtModeMexFile              = {2, ''};
  tgt.ExtModeMexArgs              = {2, ''};
  
%endfunction

% eof

