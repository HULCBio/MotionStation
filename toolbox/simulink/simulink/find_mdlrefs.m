function  varargout = find_mdlrefs(modelName, varargin)
% FIND_MDLREFS find referenced models and Model blocks
%
% find_mdlrefs finds all (or first level) Model blocks and 
% referenced models in the specified model. 
%
% find_mdlrefs should be called as follows:
%  [refMdls, mdlBlks] = find_mdlrefs(modelName,allLevels)
%
%  Inputs: 
%     modelName: is the name of the model
%     allLevels: true/false (all levels or first level) (default is true) 
%
%  Outputs:
%     refMdls: list of referenced models. 
%              This is an ordered list of models. 
%              The last element in the list is the name of 
%              the model passed in as the first input.
%     mdlBlks: list of Model blocks
  
%
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

  %% Check inputs
  if ~(nargin > 0 &&  nargin < 4)
    error('usage: find_mdlrefs(ModelName, [true/false])');
  end

  mdlsToClose = {};
  if ~ischar(modelName),
    % must be a handle to an open model
    if ~ishandle(modelName),
      error('find_mdlrefs: the first input must be a model name');
    end
    modelName = get_param(modelName,'Name');
  else
    % load the model if it is not loaded
    mdlsToClose = load_model(modelName);
  end

  nvarargs = nargin - 1;
  all = true;
  if (nvarargs > 0) 
    all = varargin{1};
    isOk = islogical(all) || ...
           (isscalar(all) && isnumeric(all) && isreal(all) ...
            && (all == 0 || all == 1));
    if ~isOk
      error('find_mdlrefs: the second input must be true/false');
    end
  end
  
  genGraphFile = false;
  %  genGraphFile: true/false 
  %                generate model dependency digraph file model.dot
  %                default : false
  if (nvarargs > 1) 
    genGraphFile = varargin{2};
    if ~islogical(genGraphFile) 
      error('find_mdlrefs: the third input must be true or false');
    end
  end
  %% Check outputs
  if nargout > 2
    error('find_mdlrefs: invalid number of output arguments');
  end
    
  [refMdls, mdlBlks, dg] =  get_all_models_and_model_blocks(modelName,{}, ...
                                                            {}, all,{},'');
  if genGraphFile > 0
    %% create model.dot file
    loc_create_dot(dg, modelName);
  end
  
  %% Fill output
  varargout{1} = refMdls;
  varargout{2} = mdlBlks;
  
  slprivate('close_models', mdlsToClose);
  
%endfunction
    
%------------------------------------------------------------------------------
function [ioRefMdls, ioMdlBlks, ioGraph] = get_all_models_and_model_blocks(...
                                                    iMdl, ...
                                                    ioRefMdls, ...
                                                    ioMdlBlks, ...
                                                    all,       ...
                                                    iPathToMdl, ...
                                                    ioGraph)
  
  mdlsToClose = slprivate('load_model', iMdl);
  
  opts = {'FollowLinks', 'on', 'LookUnderMasks', 'all'};
  aBlks = find_system(iMdl, opts{:}, 'BlockType', 'ModelReference');
  refMdls = unique(get_param(aBlks, 'ModelName'));
  
  if length(refMdls) > 0
    for idx = 1: length(refMdls)
      ioGraph = [ioGraph, iMdl, '->',  refMdls{idx}, sprintf('\n')];
    end
  end
  
  slprivate('close_models', mdlsToClose);

  ioMdlBlks = [ioMdlBlks; aBlks];


  pathToMdlRefsInMdl = [iPathToMdl, {iMdl}];
  
  if all
    nRefMdls = length(refMdls);
    for i = 1:nRefMdls,
      refMdl = refMdls{i};
      
      if ~isempty(strmatch(refMdl, pathToMdlRefsInMdl, 'exact')),
        strPathToMdl = strcat_with_separator(pathToMdlRefsInMdl, ':');
        mdlRefLoop = [strPathToMdl, ':', refMdl];
        warning(['Detected model reference loop ''', mdlRefLoop, '''']);
        continue;
      end
      
      matchIndex = strmatch(refMdl, ioRefMdls, 'exact');
      if isempty(matchIndex)
        [ioRefMdls, ioMdlBlks, ioGraph] = get_all_models_and_model_blocks(...
            refMdl, ioRefMdls, ...
            ioMdlBlks, all, pathToMdlRefsInMdl, ioGraph);
      end
    end
  else
    ioRefMdls = [ioRefMdls; refMdls];
  end
  ioRefMdls = [ioRefMdls; {iMdl}];

%endfunction

%------------------------------------------------------------------------------
%  generate model dependency digraph file model.dot file
%
function loc_create_dot(dg, modelName)
  % dot is a software for drawing directed graphs
  % 'provided by AT&T labs.
  dotFileName = [modelName,'.dot'];
  if ~isempty(dg)
    dg = ['digraph G {', sprintf('\n'), dg, '}'];
    [fid, errmsg] = fopen(dotFileName, 'w');
    if fid == -1
      error(['Error creating file ''', dotFileName, ''': ', errmsg]);
    end
    fwrite(fid, dg);
    fclose(fid);
  else
    warning(['''', modelName, ''' does not have any Model block. ', ...
             'No model reference dependency graph file (', ...
             dotFileName, ') is generated.']);
  end
%endfunction

