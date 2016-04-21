function varargout = simUtil_maskParameter(action,block,pName,pValue)
%SIMUTIL_MASKPARAMETER
%
% --- Arguments ---
%
%  action   -  'disable' | 'enable' | 'show' | 'hide' | 'get' | 'callback'
%              | 'execcallback'
%              'isenabled' | 'isVisible'
%  block    -  The block path
%  pName    -  The name of the parameter to operate on
%  pValue   -  The value of the parameter 
%              Only used for 'disable' | 'enable' | 'show' | 'hide' arguments
%
%
%  Note
%       'get' action gets the evaluated version of the parameter and is
%       usefull in mask initialization functions where it is a pain to 
%       explicitly pass the mask parameters in as arguments.
%

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:28 $

   switch lower(action)
       
      case 'disable'
         if nargin==4
            paramDisable(block,pName,pValue);
         else
            paramDisable(block,pName)
         end
      case 'enable'
         if nargin==4
            paramEnable(block,pName,pValue);
         else
            paramEnable(block,pName);
         end      
      case 'isenable'
           varargout{1} = paramIsEnable(block, pName);
      case 'show'
         if nargin==4
            paramSetVisible(block,pName,pValue);
         else
            paramSetVisible(block,pName);
         end
      case 'hide'
         if nargin == 4
            paramSetInvisible(block,pName,pValue);
         else      
            paramSetInvisible(block,pName); 
         end
      case 'isvisible'
           varargout{1} = paramIsVisible(block, pName);
      case 'callback'
         paramSetCallback(block,pName,pValue);
      case 'execcallback'
         paramExecCallback(block,pName);  
      case 'get'
         varargout= { paramGet(block,pName) };
         
      otherwise
            error([action ' is an invalid action to simUtil_maskParameter']);
  end

%------------------------------------------------------------
% Get Mask Workspace variables
%------------------------------------------------------------
function vars = paramGet(block,pName)
   im = ismember(pName,get_param(block,'masknames'));
   if ~all(im)
      error((sprintf('%s\n',pName{~im},'are not mask parameter names for block ', block )));
   end
   ws = get_param(block,'maskWSVariables');
   [c,i,ib] = intersect(pName,{ws.Name});
   i = sortrows([i' ib']);
   vars = { ws(i(:,2)).Value };
   if length(vars) == 1
       vars = vars{1};
   end

         
%------------------------------------------------------------
%  Set a parameters callback
%------------------------------------------------------------
function paramSetCallback(block,pName,pValue)
   enables = get_param(block,'MaskCallbacks');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   [enables{i}]=deal(pValue);
   set_param(block,'MaskCallbacks',enables);
   
function paramExecCallback(block, pName)
   callbacks = get_param(block,'MaskCallbacks');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names, pName);
   callback = callbacks{i};
   evalin('base', callback);
   

%------------------------------------------------------------
%  Disable a parameters and optionally set its value
%------------------------------------------------------------
function paramDisable(block,pName,pValue)
   enables = get_param(block,'MaskEnables');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   [enables{i}]=deal('off');
   set_param(block,'MaskEnables',enables);
   if nargin == 3
      set_param(block,pName,pValue);
   end

%------------------------------------------------------------
%  Enable a parameter and optionally set its value
%------------------------------------------------------------
function paramEnable(block,pName,pValue)
   enables = get_param(block,'MaskEnables');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   [enables{i}]=deal('on');
   set_param(block,'MaskEnables',enables);
   if nargin == 3
      set_param(block,pName,pValue);
   end

function out = paramIsEnable(block, pName)
  enables = get_param(block,'MaskEnables');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   out = strcmp(enables{i},'on');
   

%------------------------------------------------------------
% Make a parameter invisible and optionally set its value
%------------------------------------------------------------
function paramSetInvisible(block,pName,pValue)
   enables = get_param(block,'MaskVisibilities');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   [enables{i}] = deal('off');
   set_param(block,'MaskVisibilities',enables);
   if nargin == 3
      set_param(block,pName,pValue);
   end

%------------------------------------------------------------
% Make a parameter visible and optionally set its value
%------------------------------------------------------------
function paramSetVisible(block,pName,pValue)
   enables = get_param(block,'MaskVisibilities');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   [enables{i}] = deal('on');
   set_param(block,'MaskVisibilities',enables);
   if nargin == 3
      set_param(block,pName,pValue);
   end

function out = paramIsVisible(block, pName)
   enables = get_param(block,'MaskVisibilities');
   names = get_param(block,'MaskNames');
   [c,i,ib]=intersect(names,pName);
   out = strcmp(enables{i},'on');
          
   
