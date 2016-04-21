function varargout = dspFixptManager(action,blk)

% dspFixptManager(action, pathname)
%
% actions not requiring pathname (uses gcb if needed):
%    addController     - adds block as new DSP FPA
%    removeController  - removes block from DSP FPA
%                        hierarchy
%    closeModel        - marks parent model as closing. Model
%                        is removed when all its DSP FPAs
%                        are gone
%    changeName        - called when a DSP FPA's name or path
%                        changes
%    openUI            - the open function for a DSP FPA block
%    returnUI          - returns the FixptUI java object
%    returnModels      - returns vector of ModelInfo objects
%    returnControllers - returns vector of Controller objects
% actions requiring pathname:
%    loadModel         - called when a model with DSP FPAs 
%                        is loaded. Root model name is passed
%                        in as pathname
%    getAttributes     - used by NON-DSP FPAs to get their
%                        overrides. full block name passed in
%                        as pathname

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/04/12 23:05:10 $

% blk/sys setting
switch action
  % ACTIONS CALLED BY A CONTROLLER BLOCK (blk is gcb)
 case {'addController', 'removeController', 'openUI', ...
       'changeName', 'closeModel'}
  blk = gcb;
  sys = bdroot(blk);
  % do nothing if this is a block in a library
  if strcmp(get_param(sys,'BlockDiagramType'),'library')
    % return an empty matrix to make sure dspGetFixptDTI works
    varargout = {[]};
    return;
  end
  
  % ACTIONS CALLED BY NON-CONTROLLER BLOCK (blk is passed in)
 case 'getAttributes'
  if ~isstr(blk)
    try 
      blk = getfullname(blk);
    catch
      error('Invalid block passed in to dspFixptManager:getAttributes');
    end
  end
  sys = bdroot(blk);
  
  % ACTIONS CALLED BY MODEL (sys passed in as blk)
 case 'loadModel'
  sys = blk;
  
  % ACTIONS CALLED BY UI (mixed)
 case {'updateUDDFromBlocks', 'updateBlocksFromUDD'}
  % global commands, no blk or sys needed
  blk = '';
  sys = '';
 case 'updateAttributesFromBlock'
  % blk passed in 
  sys = bdroot(blk);
 case 'propagateAttributesChange'
  % blk passed in - sys may fail if model just closed
  sys = '';
  
  % ACTIONS CALLED FROM COMMAND LINE (no need for blk or sys)
 case {'returnModels', 'returnControllers', 'returnUI'}
  blk = '';
  sys = '';
  
  % OTHERWISE
 otherwise 
    error ('unknown action')
end

% Need to keep those persistent variables around
mlock;

persistent models;
persistent controllers;
persistent gui;
persistent updatingStructure;

javacheck = javachk('swing');
if ~isempty(javacheck) && ~strcmp(action,'getAttributes')
  error('The DSP Fixed-Point Attributes block requires the Java Virtual Machine to be running with swing support');
end
if isempty(gui) && ~strcmp(action,'getAttributes')
  gui = com.mathworks.toolbox.dspblks.FixptUI.getUI;
end
if isempty(updatingStructure)
  updatingStructure = 0;
end

postLoadFcn = 'dspFixptManager(''loadModel'',bdroot(gcs));';
maskType = 'DSP Fixed-Point Attributes';

switch(action)
  % OPEN UI
 case 'openUI'
  varargout = {};
  if updatingStructure
    return;
  end
  [mi,models] = findModel(sys,models,gui);
  if isempty(mi), return; end
  con = mi.findController(blk);
  if isempty(con), return; end
  if ~gui.isShowing
    gui.showUI;
  end
  gui.selectController(con.getNode);

  % ADD CONTROLLER
 case 'addController'
  %disp('dspFPM::addController')
  updatingStructure = 1;
  [mi, models] = findModel(sys, models,gui);
  retStruct = mi.addController(blk,gui);
  if retStruct.needUpdate
    gui.updateStructure(mi.getNode);
  end
  if ~isempty(retStruct.con)
    controllers = [controllers retStruct.con];
    if gui.isShowing
      gui.selectController(retStruct.con.getNode);
    end
  end
  updatingStructure = 0;
  plf = get_param(sys,'postloadfcn');
  % Add the PostLoadFcn if it's not already there
  if isempty(findstr(plf,'dspFixptManager'))
    plf = [postLoadFcn plf];
    set_param(sys,'postloadfcn',plf);
  end
  varargout = {};
  %disp('dspFPM::addController - done')  

  % REMOVE CONTROLLER
 case 'removeController'
  %disp('dspFPM::removeController')
  updatingStructure = 1;
  [mi, models] = findModel(sys, models, gui);
  mi.removeController(blk,gui);
  if ~mi.isClosing
    % if the model IS closing ,no need to update the structure -
    % it's going away (plus, this speeds up model closing)
    gui.updateStructure(mi.getNode);
  end
  if  (isempty(mi.getRootControllers))
    if ~mi.isClosing
      % If the model is NOT closing, and all of the root controllers
      % are gone, then remove the PostLoadFcn
      plf = get_param(sys,'postloadfcn');
      ind = findstr(plf,'dspFixptManager');
      if ~isempty(ind)
        set_param(sys,'postloadfcn', ...
                      plf([1:ind-1,ind+length(postLoadFcn):length(plf)]));
      end
    end
    % Remove the model from the model list when all of the controllers
    % are gone
    gui.removeModelInfoNode(mi.getNode);
    models = setdiff(models,mi);
    % close the gui if all the models are closed
    if isempty(models) 
      gui.hideUI; 
    end
  end
  varargout = {};
  updatingStructure = 0;
  %disp('dspFPM::removeController - done')
  
  % CHANGE NAME
 case 'changeName'
  %disp('dspFPM::changeName')
  updatingStructure = 1;
  mi = findModel(sys,models,gui,0);
  if isempty(mi)
    % a model name has changed
    openModels = find_system('type','block_diagram');
    for mdlInd = 1:length(models)
      mi = models(mdlInd);
      miInd = strmatch(mi.getName,openModels,'exact');
      if isempty(miInd);
        break;
      end
    end
    mi.setName(sys);
  end
  % now that we've found the right model...
  % check to see if blk is a controller in mi.  If not, rebuild mi
  % if so, this name change has already been processed (nothing more to 
  % do)
  if ~mi.isController(blk)
    mi.clearAll(gui);
    gui.updateStructure(mi.getNode);
    cons = find_system(sys,'masktype',maskType);
    for conInd = 1:length(cons)
      retStruct = mi.addController(cons{conInd},gui);
      if ~isempty(retStruct.con)
        controllers = [controllers retStruct.con];
      end
    end 
  end
  updatingStructure = 0;
  varargout = {};
  %disp('dspFPM::changeName - done')

 % LOAD MODEL
 case 'loadModel'
  %disp('dspFPM::loadModel')
  % add existing controllers to tree
  updatingStructure = 1;
  [mi, models] = findModel(sys, models, gui);
  cons = find_system(sys,'masktype',maskType);
  for conInd = 1:length(cons)
    retStruct = mi.addController(cons{conInd},gui);
    if ~isempty(retStruct.con)
      controllers = [controllers retStruct.con];
    end
  end
  updatingStructure = 0;
  varargout = {};
  %disp('dspFPM::loadModel - done')
  
 % CLOSE MODEL
 case 'closeModel'
  %disp('dspFPM::closeModel')
  [mi, models] = findModel(sys, models, gui);
  mi.setClosing(1);
  varargout = {};
  %disp('dspFPM::closeModel - done')
  
 % GET ATTRIBUTES
 case 'getAttributes'
  if ~isempty(javacheck)
    varargout = {[]};
    return;
  end
  mi = findModel(sys,models, gui, 0);
  attrs = [];
  if ~isempty(mi)
    attrs = mi.getAttributes(blk);
  end
  varargout = {attrs};
  
  % UPDATE ATTRIBUTES
 case 'updateAttributesFromBlock'
  %disp('dspFPM::updateAttributesFromBlock')
  [mi,models] = findModel(sys, models, gui, 0);
  con = mi.findController(blk);
  con.updateAttributesFromLocal;
  varargout = {};
  %disp('dspFPM::updateAttributesFromBlock - done')
  
  % PROPAGATE ATTRIBUTES CHANGE
 case 'propagateAttributesChange'
  %disp(['dspFPM::propagateAttributesChange - ' blk])
  try
    sys = bdroot(blk);
  catch
    varargout = {};
    return
  end
  [mi,models] = findModel(sys, models, gui, 0);
  if ~isempty(mi)
    % mi might be empty if the model was just closed
    con = mi.findController(blk);
    con.updateChildrenAttributes;
  end
  varargout = {};
  %disp('dspFPM::propagateAttributesChange - done')
 
  % APPLY CHANGES FROM UI
 case 'updateBlocksFromUDD' 
  for i=1:length(models)
    models(i).applyChanges;
  end
  varargout = {};
  
  % CANCEL CHANGES FROM UI
 case 'updateUDDFromBlocks' 
  for i=1:length(models)
    models(i).cancelChanges;
  end
  varargout = {};

  % RETURN MODELS
 case 'returnModels'
  varargout = {models};
 
  % RETURN CONTROLLERS
 case 'returnControllers'
  varargout = {controllers};
 
  % RETURN UI
 case 'returnUI'
  %disp('dspFPM::returnUI')
  varargout = {gui};
  %disp('dspFPM::returnUI - done')
  
end

%------------------------------------------
function [mi, models] = findModel(model, models, gui, register)
  
mi = {};
if nargin == 3, register = 1; end;

for i=1:length(models)
  if strcmp(models(i).getName,model)
    mi = models(i);
    break;
  end
end

if register && isempty(mi)
  mi = dspfpa.ModelInfo(model);
  mi.setNode(gui.addModelInfoNode(mi.getBean));
  models = [models, mi];
end
  
%-------------------------------------------
