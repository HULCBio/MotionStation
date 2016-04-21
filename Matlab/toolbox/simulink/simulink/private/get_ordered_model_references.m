function [ioMdlRefs, ioPathToMdlRefs, ioDirtyFlags] = ...
  get_ordered_model_references(iMdl, ...
                               targetType, ...
                               iPathToMdl, ...
                               ioMdlRefs, ...
                               ioPathToMdlRefs, ...
                               ioDirtyFlags)
% Abstract:
%   Does a depth first traversal to return an ordered list of all models
%   referenced from within the specified (top) model. The depth first search
%   ensures that all the models referenced from within a certain model are above
%   it in the list (hence the word ordered in the name). This property of the
%   list is used in the checking and updating the model reference targets.
%
% Syntax:
%   [ioMdlRefs, ioPathToMdlRefs] = ...
%       get_ordered_model_references(iMdl, ...
%                                    ioMdlRefs, ...
%                                    ioPathToMdlRefs, ...
%                                    iPathToMdl)
% Inputs:
%   iMdl            : (string)  Name of the model to deep dive into looking
%                               for model references.
%
%   iPathToMdl      : (cellstr) A cell array for models names determining the
%                               reference chain from the top model to iMdl.
%                               This argument is used for detecting loops.
%
%   ioMdlRefs       : (cellstr) List of model references found so far.
%   ioPathToMdlRefs : (cellstr) A cell array of colon (:) separated strings
%                               indicating the chain of references that lead
%                               to each entry in the ioMdlRefs list.
%   ioDirtyFlags    : (logical vector) indicating the dirty status of ioMdlRefs
%
% Outputs:
%   ioMdlRefs       : (cellstr) Updated version ioPathToMdlRefs, i.e., of list
%                               of model references after visiting iMdl and all
%                               references within it.
%   ioPathToMdlRefs : (cellstr) Updated version of the input argument
%
%   ioDirtyFlags    : (logical vector) indicating the dirty status of ioMdlRefs
%
% Notes:
%   1. This function throws an error if a model reference loop is detected.

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.8.7 $

  % Get the list the models referenced (expanding all library links) at this
  % level (i.e., in iMdl) and cache away this list in an info mat file for
  % later use.

  anchorDir = pwd;
  cache=rtwprivate('rtwinfomatman',anchorDir,'update','model',iMdl,targetType);
  mdlRefs = cache.modelRefs;
  nMdlRefs = length(mdlRefs);

  mdlDirtyFlag = ~isModelClosed(iMdl) && isequal(get_param(iMdl,'Dirty'),'on');

  strPathToMdl = '';
  if ~isempty(iPathToMdl),
    strPathToMdl = strcat_with_separator(iPathToMdl, ':');
  end

  pathToMdlRefsInMdl = [iPathToMdl, {iMdl}];

  for i = 1:nMdlRefs,
    mdlRef = mdlRefs{i};
    mdlRefIsMultiInst = false;
    
    if ~isvarname(mdlRef)
      %% The only time that we can be here, when the
      %% model name is <Enter Model Name>
      error(['Model name parameter of one of the Model blocks ', ...
             'in Model ''', iMdl, ''' is ''', mdlRef, '''. ', ...
             'Model name must be a valid Matlab identifier']);
    end
    
    if ~isempty(strmatch(mdlRef, pathToMdlRefsInMdl, 'exact')),
      mdlRefLoop = [strPathToMdl, ':', iMdl, ':', mdlRef];
      error(['Detected model reference loop ''', mdlRefLoop, '''']);
    end
    
    % If the model is in the list do not add it to the list again
    if ~isempty(strmatch(mdlRef, ioMdlRefs, 'exact')) 
      continue;
    end

    % visit mdlRef (recursive call)
    [ioMdlRefs, ioPathToMdlRefs, ioDirtyFlags] ...
        = get_ordered_model_references(mdlRef, ...
                                       targetType, ...
                                       pathToMdlRefsInMdl, ...
                                       ioMdlRefs, ...
                                       ioPathToMdlRefs, ...
                                       ioDirtyFlags);
  end

  % we have visited all models referenced from within iMdl, now add iMdl to list
  ioMdlRefs           = [ioMdlRefs; {iMdl}];
  ioPathToMdlRefs     = [ioPathToMdlRefs; {strPathToMdl}];
  ioDirtyFlags(end+1) = mdlDirtyFlag;

% endfunction
