function fixpt_update(ModelName)
%FIXPT_UPDATE  Update fixed-point blocks to latest version 
%
% Syntax:
%   FIXPT_UPDATE(ModelName);
%
% Inputs:
%   - ModelName   name of model to be updated
%
% See also FPUPDATE, SLUPDATE

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.2.4.2 $
% $Date: 2004/04/14 23:59:19 $

if nargin < 1
  ModelName = bdroot;
end


% ==============================================================================
% Define Default Settings Here:
% ==============================================================================

%
% Set defaults for fixed point specific parameters
% 
fixPtDefaults = struct('GainDataType',  'evalin(''base'',''BaseType'')', ... 
                       'GainScaling',   '2^0', ...
                       'MatRadixGroup', 'Best Precision: Matrix-wise', ...
                       'ConRadixGroup', 'Best Precision: Vector-wise', ...
                       'VecRadixGroup', 'Best Precision: Vector-wise', ... 
                       'LookUpMeth',    'Interpolation-Use End Values', ...
                       'OutDataType',   'evalin(''base'',''BaseType'')' , ...
                       'LogicDataType', 'evalin(''base'',''LogicType'')', ...
                       'OutScaling',    '2^0', ...
                       'LockScale',     'off', ...
                       'RndMeth',       'Floor', ...
                       'DoSatur',       'off', ...
                       'DblOver',       'off', ...
                       'dolog',         'on');
                
% List of block properties to be copied for all 1-1 block replacements
commonParamNamesToCopy = { 
                           'Orientation'
                           'Position'
                           'NamePlacement'
                           'AttributesFormatString'
                           'Description'
                           'Priority'
                           'Tag'
                         };

% Paired list of 1-1 block replacements
old_new = {};

old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nResize';
old_new{end  }.newBlk        = 'fixpt_update_20000313_3p1/Resize';
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};



old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nConstant';
old_new{end  }.newBlk        = fixptlibname({'Constant'},'Block');
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};
old_new{end  }.extraMatchParamName  = {'SpecifyOutputDataType','SpecifyOutputScaling'};
old_new{end  }.extraMatchParamValue = {'on',                   'on'                  };

old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nConstant';
old_new{end  }.newBlk        = 'fixpt_update_20000313_3p1/Constant Inherit Scale';
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};
old_new{end  }.extraMatchParamName  = {'SpecifyOutputDataType','SpecifyOutputScaling'};
old_new{end  }.extraMatchParamValue = {'on',                   'off'                 };

old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nConstant';
old_new{end  }.newBlk        = 'fixpt_update_20000313_3p1/Constant Inherit DT';
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};
old_new{end  }.extraMatchParamName  = {'SpecifyOutputDataType','SpecifyOutputScaling'};
old_new{end  }.extraMatchParamValue = {'off',                   'on'                 };

old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nConstant';
old_new{end  }.newBlk        = 'fixpt_update_20000313_3p1/Constant Inherit Both';
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};
old_new{end  }.extraMatchParamName  = {'SpecifyOutputDataType','SpecifyOutputScaling'};
old_new{end  }.extraMatchParamValue = {'off',                  'off'                 };



old_new{end+1}.originalBlk   = 'fixptlib/FixPt\nGain';
old_new{end  }.newBlk        = fixptlibname({'Gain'},'Block');
old_new{end  }.oldParamNames = {};
old_new{end  }.newParamNames = {};
old_new{end  }.extraMatchParamName  = {'SpecifyOutputDataTypeAndScaling'};
old_new{end  }.extraMatchParamValue = {'on'};
old_new{end  }.forceParamName  = {'OutputDataTypeScalingMode'};
old_new{end  }.forceParamValue = {'Specify via dialog'};

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nSum';
old_new{end  }.newBlk        = fixptlibname({'Sum'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nProduct';
old_new{end  }.newBlk        = fixptlibname({'Product'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nMatrix\nGain';
old_new{end  }.newBlk        = fixptlibname({'Matrix','Gain'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nFIR';
old_new{end  }.newBlk        = fixptlibname({'FIR'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nDot\nProduct';
old_new{end  }.newBlk        = fixptlibname({'Dot','Product'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};



old_new{end+1} = old_new{end-1};
old_new{end  }.originalBlk   = 'fixptlib/FixPt\nMinMax';
old_new{end  }.newBlk        = fixptlibname({'MinMax'},'Block');

old_new{end+1} = old_new{end};
old_new{end  }.extraMatchParamValue = {'off'};
old_new{end  }.forceParamValue = {'Inherit via internal rule'};

                 
% =====================================================================
% CONVERSION PROCESS STARTS HERE.
% =====================================================================

if strcmp(ModelName,'fixptlib')
  error('The library fixptlib can not be updated by this script.  This library must be left as it is for old models to be update-able.');
  return;
end

% =====================================================================
% Open the model and prepare it for conversion
% =====================================================================
open_system(ModelName)

% If model is a library - unlock it & change names accordingly.
if strcmp(get_param(ModelName,'BlockDiagramType'), 'library')
  set_param(ModelName, 'Lock', 'off');
end    

% =====================================================================
% Loop through each of the blocks in the paired list of 1-1 replacements. 
% =====================================================================

% Create temporary subsystem.
tempSystem = tempmdl;
tempBlock = [tempSystem, '/tempBlock'];
if any(strcmp(tempSystem,find_system('SearchDepth',0)))
  bdclose(tempSystem)
end
new_system(tempSystem); 

% Loop through each of the pairs of 1-1 replacement blocks.
for i=1:length(old_new)
    
  old_block = sprintf( old_new{i}.originalBlk );
  new_block = sprintf( old_new{i}.newBlk     );
    
  findBlocksStr = 'find_system(ModelName,''LookUnderMasks'',''all'',''ReferenceBlock'',old_block';

  if isfield(old_new{i},'extraMatchParamName')
    for k = 1:length(old_new{i}.extraMatchParamName)
    
      kStr = num2str(k);
      
      findBlocksStr = [findBlocksStr, ',old_new{i}.extraMatchParamName{', kStr, '}, old_new{i}.extraMatchParamValue{', kStr, '}'];    
    end
  end
   
  findBlocksStr = [findBlocksStr, ');'];
  
  matchBlocks = eval(findBlocksStr);
  
  % If any old_blocks are found - perform replacement:
  if ~isempty(matchBlocks)

    load_system(strtok(new_block,'/'));
    
    % Set up lists of block properties to copy:
    newParamNames = get_param(new_block, 'MaskNames');
    newParamNames = {newParamNames{:}, commonParamNamesToCopy{:}}';
        
    oldParamNamesToTranslate = old_new{i}.oldParamNames;
    
    newParamNamesToTranslate = old_new{i}.newParamNames;
  
    %
    % Perform replacement for each of old_blocks found (elements of matchBlocks)
    %
    for j = 1:length(matchBlocks)
    
      thisBlock = matchBlocks{j};
                        
      oldObjectParams = get_param(thisBlock, 'objectparameters');
      
      newParams = newParamNames;
      
      for k=1:size(newParamNames, 1)
      
        curNewParamName = newParamNames{k};

        ii =find( strcmp( curNewParamName, newParamNamesToTranslate ) );
        
        if isfield(old_new{i},'forceParamName')
          jj =find( strcmp( curNewParamName, old_new{i}.forceParamName ) );
        else
          jj = [];
        end
        
        if ~isempty(jj)
          %
          % handle case of forcing parameter to a specific value
          %
          newParams{k} = old_new{i}.forceParamValue{jj};      
        
        elseif ~isempty(ii)
          %
          % handle case of translating parameter name
          %
          newParams{k} = get_param(thisBlock, oldParamNamesToTranslate{ii} );  
              
        else        
          
          if isfield(oldObjectParams,curNewParamName)
            %
            % handle parameters that exist on old block under same name
            %
            newParams{k} = get_param(thisBlock, curNewParamName);    
              
          elseif isfield(fixPtDefaults, curNewParamName)
            %
            % resort to default values
            %
            newParams{k} = getfield(fixPtDefaults, newParamNames{k}); 
          else
            %
            % just leave value at default
            %
            newParams{k} = NaN; 
          end   
        end       
      end
            
      % Compose string for adding new replacement block
      % NOTE: Using "string" approach because we want to set
      %       all the old parameters simultaneously
      addStr = ['add_block(new_block, tempBlock'];

      for k = 1:length(newParamNames)
        if ~isnan(newParams{k})
          kStr = num2str(k);
          addStr = [addStr, ',newParamNames{', kStr, '}, newParams{', kStr, '}'];
        end
      end
      addStr = [addStr, ');'];
            
      % Add new block to temporary system using "addStr" created above
      eval( addStr );

      Size = get_param(thisBlock, 'Position');
      
      breakCircularLinks(thisBlock,tempBlock);

      delete_block(thisBlock);
      
      add_block(tempBlock, thisBlock, 'Position', Size);
      
      delete_block(tempBlock);
    end
  end
end

% Remove temporary system (if it exists)
bdclose (tempSystem)

%
% break circular links
%   tempBlock will be used to replace origBlock (later not here).  If tempBlock
%   contains any links to origBlock, then a bad circular link could be created.
%   To prevent this, any such links are broken here. 
%
function breakCircularLinks(origBlock,tempBlock)

totalWhiles = 0;

keepGoing = 1;

while keepGoing

  keepGoing = 0;

  totalWhiles = totalWhiles + 1;
  
  if totalWhiles > 100
      error('fixpt_update was trying to break circular links, but appears to be stuck in an infinite loop.')
  end
    
  tempBlks = find_system( tempBlock,'LookUnderMasks','all');

  for i=1:length(tempBlks)
  
    refBlk = get_param(tempBlks{i},'ReferenceBlock');

    ii = findstr( refBlk, origBlock );
    
    if ~isempty(ii) & ii(1) == 1
      set_param(tempBlks{i}, 'LinkStatus', 'none')

      keepGoing = 1;
    end
  end
end

function [mdl,mdlFullPath]=tempmdl
%TEMPMDL Return a unique block diagram name.
%   TEMPMDL returns the name of a nonexistent model.  The
%   model name is neither an MDL file nor is it a block diagram
%   in memory created by NEW_SYSTEM.
%
%   See also: NEW_SYSTEM, TEMPNAME

lastSlDiagCache = get_param(0,'LastDiagnostic');
lastErrCache    = lasterr;
lastWarnCache   = lastwarn;

while 1
  [ mdlpath, mdlfile, mdlext, mdlver ] = fileparts(tempname);
  mdl=mdlfile;
  if ~exist(mdl) 
    try
      find_system(mdl,'SearchDepth',0);
    catch
      mdlFullPath = [fullfile(mdlpath, mdlfile) '.mdl'];
      break;
    end
  end
end

set_param(0,'LastDiagnostic',lastSlDiagCache);
lasterr(lastErrCache);
lastwarn(lastWarnCache);
% end tempmdl
