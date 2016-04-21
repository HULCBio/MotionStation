function y = modeldeps(iMdl)
% MODELDEPS(MODEL) attempts to discover the files a model needs to run.
% It attempts to discover the M-file, MEX-file, MDL-file (library) and
% MAT-file dependencies of the model whose name is passed in.  It does not claim
% to be even close to complete, i.e. it can miss many dependencies.  It is
% intended to help generate a list of model dependencies for use in zipping up a
% model and its dependencies and checking dependencies' time stamps for
% incremental code generation.
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  y = {};
  
  [aMdlPath aMdl] = fileparts(iMdl); % strip path and extension from iMdl

  % We need to either add aMdlPath to the path or cd to it.  We chose cd: which is
  % better?
  
  if ~isempty(aMdlPath)
    startcd = cd(aMdlPath);
  end
  
  try
    
    SilentFEval('load_system', aMdl);
    
    try
  
      y = union(y, GetMDeps(aMdl));
      y = union(y, GetMatDeps(aMdl));
      y = union(y, GetSfcnDeps(aMdl));
      y = union(y, GetLibDeps(aMdl));
      
    catch
      SilentFEval('close_system', aMdl);
      error(lasterr)
    end 
    
    SilentFEval('close_system', aMdl);
 
  catch
    if ~isempty(aMdlPath)
      cd(startcd);
    end
    error(lasterr)
  end
  
  if ~isempty(aMdlPath)
    cd(startcd);
  end

%endfunction modeldeps


function y = FilteredDepFun(iFile)
%
%
% This is our own version of depfun where we do our own recursion (preventing
% depfun from recursing by using '-toponly').  We do this because we assume that
% the common case is to only need top level, i.e. we assume the common case is
% that even at top level, all the dependencies are toolbox, not user-written.

  %disp(['FilteredDepFun: examining ' iFile]);
  
  x = SilentFEval('depfun', '-nographics', '-toponly', iFile);
  
  x = PruneToolboxFiles(x);
  
  x = {x{~strcmp(x, iFile)}}; % prune out iFile itself to prevent inf. recursion
  
  y = foreach(x, {@FilteredDepFun});
  
  y = [y{:}];
  
  y = union(y,x);

  
%endfunction
  

function y = NotInToolbox(iFile)
  
  f = strfind(iFile, fullfile(matlabroot,'toolbox',''));

  y = ~strcmp(iFile, 'built-in') && ... % which('simulink') returns 'built-in'
      (isempty(f) || f(1) ~= 1);

%endfunction


function varargout = SilentFEval(varargin)
  
  cmd = [varargin{1} '(varargin{2:end})'];
  
  varargout = cell(1,nargout);

  [aCapturedOutput varargout{:}] = evalc(cmd);
    
  %disp(aCapturedOutput);
  
%endfunction SilentFEval


function PrintLineIfNotEmpty(iFileID, iFmt, iStr)
  
  if ~isempty(iStr)
    
    iStr = regexprep(iStr, '[@&]\d', 'foo'); % neutralize some stuff like &1 and @3
    
    fprintf(iFileID, iFmt, iStr);
    
  end


function oTempMFile = GenTempMFile(iMdl)
  
  oTempMFile = [tempname '.m'];
  
  fid = fopen(oTempMFile, 'w');
  
  fprintf(fid, 'function f()\n'); % Depfun has a segv on some scripts (g145803) so
                                  % we need to give it a function not a script.
  
  foreach(GetStatements(iMdl), {@PrintLineIfNotEmpty, fid, '%s\n'});
  
  fprintf(fid, '%% Misc. Matrix contents incl. S-Function Parameters\n');
  
  foreach(GetMatrixContents(iMdl), {@PrintLineIfNotEmpty, fid, '[%s]\n'});
  
  fclose(fid);
  
%endfunction GenTempMFile


function y = GetMatrixContents(iMdl)
  
  y = [...
      GetPrmsOfAllBlksOfType(iMdl, 'S-Function', {'Parameters'})...
      ];
  
function y = GetStatements(iMdl)
  
  aCmnFcns = CmnFcns;
  aSubsysAndSfcnFcns = SubsysAndSfcnFcns;
  
  aMdlFcns = {...
      aCmnFcns{:},...
      'DeleteChildFcn',...
      'PreLoadFcn',...
      'PostLoadFcn'...
      };
  
  aSubsysFcns = {...
      aSubsysAndSfcnFcns{:},...
      'DeleteChildFcn',...
      'ErrorFcn'...
      };
  
  aSfcnFcns = {...
      aSubsysAndSfcnFcns{:},...
      };
  
  y = [...
      {'% Model Functions'}...
      foreach(aMdlFcns, {@get_param, iMdl})...
      ...
      {'% Subsystem Functions'}...
      GetPrmsOfAllBlksOfType(iMdl, 'SubSystem', aSubsysFcns)...
      ...
      {'% S-Function Functions'}...
      GetPrmsOfAllBlksOfType(iMdl, 'S-Function', aSfcnFcns)...
      ...
      {'% TransferFcn Parameters'}...
      GetPrmsOfAllBlksOfType(iMdl, 'TransferFcn', {'Numerator', 'Denominator'})...
      ...
      {'% MATLABFcns'}...
      GetPrmsOfAllBlksOfType(iMdl, 'MATLABFcn', {'MATLABFcn'})...
      ...
      {'% Subsystem Mask Callbacks'}...
      GetMaskCallbacks(iMdl, 'SubSystem')...
      ...
      {'% S-Function Mask Callbacks'}...
      GetMaskCallbacks(iMdl, 'S-Function')...
      ];
  
  % xxx to do: TransferFcn's parameters (examined above) are just some of many
  % block parameters that could have M-files called in them.  Ideally, these
  % should somehow all be identified (ouch!).
  
  
function y = GetMaskCallbacks(iMdl, iBlkTyp)

  aBlks = LocFullFindSys(iMdl, 'BlockType', iBlkTyp);
  
  y = get_param(aBlks, 'MaskCallbacks');
  
  y = foreach(y, {@transpose});
  
  y = [y{:}];

  y = reshape(y,1,[]); % flatten y
    

function y = GetPrmsOfAllBlksOfType(iMdl, iBlkTyp, iPrms)
  
  aBlks = LocFullFindSys(iMdl, 'BlockType', iBlkTyp);
  
  y = foreach(iPrms, {@get_param, aBlks});
  
  y = [y{:}];
  
  y = reshape(y,1,[]); % flatten y


function y = LocFullFindSys(iMdl, varargin)
  
  opts = {'FollowLinks', 'on', 'LookUnderMasks', 'all'};
  
  y = find_system(iMdl, opts{:}, varargin{:});


function y = GetMDeps(iMdl)

  y = {};
  
  f = GenTempMFile(iMdl);
  d = dir(f);
  if d.bytes ~= 0
    y = FilteredDepFun(f);
  end
  delete(f);
  

function y = GetMatDeps(iMdl)
  
  % xxx to do: need to somehow catch "load" calls
  
  x = GetPrmsOfAllBlksOfType(iMdl, 'FromFile', {'FileName'});
  
  y = foreach(x, {@which});
  

function y = GetSfcnDeps(iMdl)
%
% Checks for M-file and MEX-file S-Functions
  
  x = [GetPrmsOfAllBlksOfType(iMdl, 'S-Function', {'FunctionName'})
       GetPrmsOfAllBlksOfType(iMdl, 'ModelReference', {'ModelName'})];
  
  x = foreach(x, {@which});
  
  x = PruneToolboxFiles(x);
  
  aMFileSFcns = {x{cell2mat(foreach(x, {@exist})) == 2}};
  
  y = foreach(aMFileSFcns, {@FilteredDepFun});
  
  y = [y{:}];
  
  y = union(y,x);
 

function y = CmnFcns
  
  y = {...
      'PreSaveFcn',...
      'PostSaveFcn',...
      'CloseFcn',...
      'InitFcn',...
      'StartFcn',...
      'StopFcn'...
      };


function y = SubsysAndSfcnFcns
  
  aCmnFcns = CmnFcns;

  y = {...
      aCmnFcns{:},...
      'MaskInitialization',...
      'MaskDisplay',...
      'CopyFcn',...
      'DeleteFcn',...
      'UndoDeleteFcn',...
      'LoadFcn',...
      'ModelCloseFcn',...
      'NameChangeFcn',...
      'ClipboardFcn',...
      'DestroyFcn',...
      'OpenFcn',...
      'ParentCloseFcn',...
      'MoveFcn'...
      };


function y = GetLibDeps(iMdl)
  
  aReferringBlks = LocFullFindSys(iMdl, 'Regexp', 'on', 'ReferenceBlock', '.+');
  
  aReferredToBlks = get_param(aReferringBlks, 'ReferenceBlock');
  
  aBdRoots = unique(foreach(aReferredToBlks, {@bdroot}));
  
  y = foreach(aBdRoots, {@which});
  
  y = PruneToolboxFiles(y);
  
  
function y = PruneToolboxFiles(x)
  
  y = {x{cell2mat(foreach(x, {@NotInToolbox}))}};
  