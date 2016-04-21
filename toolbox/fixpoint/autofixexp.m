function autofixexp(FixPtVerbose,RangeFactor,curFixPtSimRanges,topSubSystemToScale)
%AUTOFIXEXP  Automatically scales the fixed point blocks in a model.
%
% This script automatically changes the scaling on
% all Fixed Point blocks that do not have their scaling locked.
% This file uses min-max data obtain from the last simulation run.

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.22.4.8 $  
% $Date: 2004/04/14 23:59:11 $

%
% turn on/off choice for lots of messages
%
if nargin < 1
    FixPtVerbose = 1;
end
WarningsOccurred = 0;

%
% RangeFactor specifies how much extra range the user
% wants beyond the maximum and minimum values identified
% in curFixPtSimRanges.
%    A value of 1.55 specifies that a range AT LEAST 55 percent'
% larger is desired.  A value of 0.85 specifies that a range
% up to 15 percent smaller would be acceptable.
%    Note: the scaling is not exact for the radix point only 
% case, because the range is (approximately) a power of two.
% For a signed number, the range can be (approximately) plus or
% minus ... 1/8, 1/4, 1/2, 1, 2, 4, 8, ...
%    The lower limit is exact, and only the upper limit is 
% approximate.  As is well known, the upper limit is always one
% BIT below a power of two.  For example, a signed four bit integer
% has range -4 to (+4-1).  If the number is a signed four bit fixed
% point with scaling 2^-1, then each bit is worth 0.5 and the range is
% -2 to (+2-0.5).
%    As an example, if the max were 5, and the min was -0.5, then any
% RangeFactor from 4/5 to slightly under 8/5 would produce the
% same radix point.  This would be the radix point that gave a
% range of -8 to +8 (minus a bit).
% 
if nargin < 2

  if evalin('caller','exist(''RangeFactor'') == 1')
  
      RangeFactor = evalin('caller','RangeFactor');
      
  elseif evalin('base','exist(''RangeFactor'') == 1')
  
      RangeFactor = evalin('base','RangeFactor');
  else
      RangeFactor = 1;
  end
end

%
% get the global variable that
%   holds the simulation Mins and Maxs
%
if nargin < 3
  global FixPtSimRanges
  curFixPtSimRanges = FixPtSimRanges;
  clear FixPtSimRanges
end

if isempty(curFixPtSimRanges)
    errStr = [ ...
        'Autoscaling can''t be executed because no min-max data is available.  ' ...
        'Before autoscaling, a simulation must be run with logging mode on.  ' ...
        'To turn logging on, select "Fixed-Point Settings" from the ' ...
        'model''s Tools menu.  Set the interface''s "Select current ' ...
        'system" option to be the root model or the desired subsystem, ' ...
        'and set "Logging mode" to be "Min, max and overflow."' ...
        ];
    error(errStr);
    return
end

%
% display message that autoscaling is starting
%
if FixPtVerbose
   disp(' ')
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp('% FIXED POINT BLOCKSET AUTOSCALING TOOL                               %')
   disp('% curFixPtSimRanges contains signal extremums from previous simulations  %')
   disp('% These extremums will be expanded/contracted thru multiplication by  %')
   disp('%   RangeFactor = 1 + SafetyMargin/100                                %')
   disp('% Based on the adjusted extremums, radix points for block outputs     %')
   disp('% will be automatically set, if                                       %')
   disp('%   a) Output Data Type is sfix(...) or ufix(...)                     %')
   disp('%   b) Lock Output Scaling is UNCHECKED                               %')
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end

%
% a global variable is needed in order to "steal"
% parameters (such as data type) that are based on
% variables not known in the base workspace.
%   For example, suppose a FixPtSum has its output
% data type specified as "DerivedVar."  Also, assume
% that this FixPtSum is under a mask and "DerivedVar"
% is derived in the mask initialization based on mask
% parameters.  Getting the characters that spell
% "DerivedVar" are easy, but getting the VALUE of 
% "DerivedVar" is not too easy.
%    To solve this problem without reinventing the wheel,
% the value of the parameter "DerivedVar" is stolen.  This
% is accomplished by temporarily replacing "DerivedVar"
% with "stealparameter(DerivedVar)" in the dialog for FixPtSum.
% A model update is then forced.  When "stealparameter(DerivedVar)"
% is evaluated, it returns the value of "DerivedVar" 
% without modification.  However, before returning the value
% is stashed away in the global variable below.
%   The stolen value is immediately used by this proceedure and
% is not needed again.  Therefore, this proceedure can move from
% one block to the next always using the same global variable.
%   The only possibility of trouble could occur in the unlikely
% event that the user also had a variable with the 
% the exact same name "FixPtTempGlobal"
%
globalVarAlreadyUsed = any(strcmp(who('global'),'FixPtTempGlobal'));

global FixPtTempGlobal

if globalVarAlreadyUsed
   globalVar_OrigCopy = FixPtTempGlobal;
end

clear global FixPtTempGlobal
global FixPtTempGlobal
FixPtTempGlobal = curFixPtSimRanges;

%
% RangeFactor
% 
if FixPtVerbose
    disp(' ')
    disp('RangeFactor')
    disp(RangeFactor)
end

%
% get the handle for the system (ie model)
%
if nargin < 4
  topSubSystemToScale = bdroot(FixPtTempGlobal{1}.Path);
end

CurrentRoot = bdroot(topSubSystemToScale);

if FixPtVerbose
    disp(' ')
    disp('SYSTEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(' ')
    disp(CurrentRoot)
%    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end

followToOrigin_YES = 1;
followToOrigin_NO  = 0;

%
% instrument blocks to collect data for 1D lookups
%
look1d_ref = fixptlibname({'Look','Up'},'block');

curKind = 'BlockType';

look1d_type = get_param(look1d_ref,curKind);

lookup1d_blks = find_system(CurrentRoot,'LookUnderMasks','all',curKind,look1d_type);

nblocks = length(lookup1d_blks);

for i = 1:nblocks

  iFound = findBlockRecord( lookup1d_blks{i} );    
    
  FixPtTempGlobal{iFound} = instrumentParameter(FixPtTempGlobal{iFound},{'InputValues','OutputValues'}, followToOrigin_NO);
    
end

%
% instrument blocks to collect data for 2D lookups
%

look2d_ref = fixptlibname({'Look','Up','2','D'},'block');

curKind = 'BlockType';

look2d_type = get_param(look2d_ref,curKind);

lookup2d_blks = find_system(CurrentRoot,'LookUnderMasks','all',curKind,look2d_type);

nblocks = length(lookup2d_blks);

for i = 1:nblocks

  iFound = findBlockRecord( lookup2d_blks{i} );    
    
  FixPtTempGlobal{iFound} = instrumentParameter(FixPtTempGlobal{iFound},{'OutputValues','RowIndex','ColumnIndex'}, followToOrigin_NO);

end

%
% put Data Type Prop Blocks on list
%
libblk_name = fixptlibname({'Data','Type', 'Propag'},'block');

if strcmp(get_param(libblk_name, 'Mask'), 'on');
  curKind = 'MaskType';
else
  curKind = 'BlockType';
end
libblk_type = get_param(libblk_name,curKind);

libblk_instances = find_system(CurrentRoot,'LookUnderMasks','all',curKind,libblk_type);
  
nInstance = length(libblk_instances);

for iInstance = 1:nInstance

  iFound = findBlockRecord( libblk_instances{iInstance} );    
    
  FixPtTempGlobal{iFound} = instrumentParameter(FixPtTempGlobal{iFound}, ...
                                                { ...
                                                    'PropDataTypeMode', ...
                                                    'PropDataType', ...
                                                    'PropScalingMode' ...
                                                }, ...
                                                followToOrigin_NO);

  FixPtTempGlobal{iFound}.FinalScalingName = 'PropScaling';

end

%
% Split out SP Blockset blocks, which need different treatment
%
[FixPtCore,FixPtSP] = splitBlockRecords(FixPtTempGlobal);

% 
% instrument blocks to collect parameters such as data type
%

FixPtCore = instrumentParameter(FixPtCore, ...
                                { ...
                                    'OutputDataTypeScalingMode', ...
                                    'OutDataTypeMode', ...
                                    'OutDataType' ...
                                }, ...
                                followToOrigin_YES);
FixPtSP = instrumentParameter(FixPtSP, ...
                              { ...
                                  'prodOutputMode','prodOutputWordLength' ...
                                  'accumMode',     'accumWordLength'      ...
                                  'memoryMode',    'memoryWordLength'     ...
                                  'outputMode',    'outputWordLength'     ...
                              }, ...
                              followToOrigin_YES);

FixPtTempGlobal = cat(2,FixPtCore,FixPtSP);

%
% put model in compiled mode to collect information
%
storeGlobalFixPtSimRanges;

feature('EngineInterface', 1001);
interface = get_param(CurrentRoot, 'UDDObject');
init(interface);

[FixPtTempGlobal,FixPtNonOutput] = splitOutputBlockRecords(FixPtTempGlobal);

errorDuringCompiledMode = 0;
try
  % The ordering below is important, adjusting the minmax info based on
  % parameters such as breakpoints, should be done before minmax info is
  % shared across data type duplication blocks.
  %
  % Data Type propagations should be accounted for last, so that they
  % get all the benefits of sharing.
  %
  shareBreakpointMinMax(  CurrentRoot);
  shareDTDuplicateMinMax( CurrentRoot);
  connectDTPropagation(   CurrentRoot);
catch
  disp(lasterr);
  errorDuringCompiledMode = 1;
end
term(interface);
feature('EngineInterface', 0)

restoreGlobalFixPtSimRanges;

if errorDuringCompiledMode

  error('Error occurred while the model was in compiled mode.');
end

%
% reset Core and SP split after compilation
%

FixPtTempGlobal = cat(2,FixPtTempGlobal,FixPtNonOutput);
[FixPtCore,FixPtSP] = splitBlockRecords(FixPtTempGlobal);

%
% clean up
%
removeAllInstrumentation(FixPtTempGlobal);

% 
% set the new scalings
%
nblocks = length(FixPtCore);

for i = 1:nblocks
    
    if isfield(FixPtCore{i},'FinalScalingName');

      FinalScalingName = FixPtCore{i}.FinalScalingName;      

    else
      FinalScalingName = 'OutScaling';
    end
    FixPtCore{i} = getBlockParameterInfo(FixPtCore{i}, FinalScalingName, followToOrigin_YES, 'FinalScaling');      

    minValue = getFieldOrDefault(FixPtCore{i},'MinValue', Inf);
    maxValue = getFieldOrDefault(FixPtCore{i},'MaxValue',-Inf);
    
    illogicalMinMax = minValue > maxValue;

    Locked    =  strcmp( 'on',                 getFieldOrDefault(FixPtCore{i},{'Parameters','FinalScaling','LockScale'},'off') );

    Inherited = ~strcmp( 'Specify via dialog', getParamOrDefault(FixPtCore{i},'OutputDataTypeScalingMode','Specify via dialog') ) || ...
                ~strcmp( 'Specify via dialog', getParamOrDefault(FixPtCore{i},'OutDataTypeMode',          'Specify via dialog') ) || ...
                ~strcmp( 'Specify via dialog', getParamOrDefault(FixPtCore{i},'PropDataTypeMode',         'Specify via dialog') ) || ...
                ~strcmp( 'Specify via dialog', getParamOrDefault(FixPtCore{i},'PropScalingMode',          'Specify via dialog') );
  
    outScalingSettable = parameterIsSettable( FixPtCore{i}, 'FinalScaling' );

	isSFData = isfield(FixPtCore{i}, 'isStateflow');
	if isSFData
		sfDataID = getfield(FixPtCore{i}, 'dataID');
		try
			sfDataLocked = sf('get', sfDataID, '.fixptType.lock');
		catch
			sfDataLocked = 0;
		end;
		Locked = sfDataLocked;
		outScalingSettable = 1;
		
		if isfield(FixPtCore{i}, 'Parameters') && isfield(FixPtCore{i}.Parameters, 'OutDataType')
			sfDataType = struct('Class',    'FIX',...
								'IsSigned', FixPtCore{i}.isSigned,...
								'MantBits', abs(FixPtCore{i}.MantBits));
			FixPtCore{i}.Parameters.OutDataType = ...
			setfield(FixPtCore{i}.Parameters.OutDataType, 'paramValue', sfDataType);
		end;
	end;

    hasDataTypeField =   isfield(FixPtCore{i},'Parameters') && ...
                         ( ...
                           ( ...
                             isfield(FixPtCore{i}.Parameters,'OutDataType') && ...
                             isfield(FixPtCore{i}.Parameters.OutDataType,'paramValue') ...
                           ) ...
                           || ...
                           ( ...
                             isfield(FixPtCore{i}.Parameters,'PropDataType') && ...
                             isfield(FixPtCore{i}.Parameters.PropDataType,'paramValue') ...
                           ) ...
                         );
	
    %
    % is block subsystem to be scaled?
    %
    notInTopSubSystem = 1;

    curParent = get_param(FixPtCore{i}.Path,'Parent');
    
    while ~isempty(curParent)
      
      if strcmp(curParent,topSubSystemToScale)
        
        notInTopSubSystem = 0;
        break;
      end
    
      curParent = get_param(curParent,'Parent');
    end



    if illogicalMinMax || Locked || Inherited || ~outScalingSettable || notInTopSubSystem || ~hasDataTypeField
    
      doScaling = 0;
    else
      doScaling = 1;
    end


    if FixPtVerbose
        disp(' ')
        disp('BLOCK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp([FixPtCore{i}.Path])

        if ~doScaling
            disp(' ')
            disp('  Block can''t be autoscaled.')
        end
        
        if notInTopSubSystem
            disp('    Block is outside subsystem to be scaled.')
        end
        
        if illogicalMinMax
            disp('    Block''s logged minimum and maximum are not logical.')
            disp('      Block was not configured to log min max data, or ')
            disp('      block was in a subsystem that was never trigger or enabled.')
        end
        
        if Locked
            disp('    Block''s scaling is locked.')
        end

        if Inherited
            disp('    Block''s data type and/or scaling is inherited.')
        end
        
        if ~outScalingSettable
            disp('    Block''s scaling is not settable.')
        end
        
        if ~hasDataTypeField
          disp('      Block does not have expected data type field.')
        end
    end
   
    %
    % only processes blocks whose scaling is NOT LOCKED
    %
    if doScaling
            
        if isfield(FixPtCore{i}.Parameters.OutDataType,'paramValue')
        
          curOutDataType = FixPtCore{i}.Parameters.OutDataType.paramValue;
        else
          curOutDataType = FixPtCore{i}.Parameters.PropDataType.paramValue;
        end

        if ischar(curOutDataType)
        
          % The data type edit field can evaluate to a string
          try 
            % The string can be names of types like
            %  'double', 'single', 'uint8', ... 'boolean'
            % fixdt() can convert those name to an object
            %
            curOutDataType = fixdt(curOutDataType);
            
          catch
            
            try
              %
              % The string could also be the name of variable
              % in the Matlab base workspace that define the
              % data type.  
              %
              curOutDataType = evalin('base',curOutDataType);
              
            catch
              curOutDataType = struct('Class','UNKNOWN DATA TYPE: error evaluating string value entered in data type edit field');
            end
          end
        end
            
        if FixPtVerbose
            disp(' ')
            disp('Output Data Type')
            disp(curOutDataType)
        end
         
        %
        % if the class is FIX then do radix only scaling
        %
        if all( upper( curOutDataType.Class(1:2) ) == 'FI' )
   
            %
            % initialize extremums
            % some blocks have parameter that affect what the scaling should be
            %
            if isSameBlockType(FixPtCore{i}.Path,{'Look','Up'}) || ...
               isSameBlockType(FixPtCore{i}.Path,{'Look','Up','2','D'})

                vlo = min(min(FixPtCore{i}.Parameters.OutputValues.paramValue));
                vhi = max(max(FixPtCore{i}.Parameters.OutputValues.paramValue));    
            else                          
                vlo =  Inf;
                vhi = -Inf;
            end;
            %
            % update minimum as needed
            %
            v = minValue;
                    
            if v < vlo
            
                vlo = v;
                
            end
            
            %
            % update maximum as needed
            %
            v = maxValue;
                    
            if v > vhi
            
                vhi = v;
                
            end
    
            %
            % get storage class info
            %
            nbits = curOutDataType.MantBits;
    
            issigned = curOutDataType.IsSigned;

            %
            % deal with negative values for unsigned case
            %
            if ( issigned == 0 ) && ( vlo < 0 )   
                         
               WarningsOccurred = 1;
               
               disp(' ')
               disp('WARNING: MINIMUM IS NEGATIVE, BUT DATA TYPE IS UNSIGNED.')
               disp('IT IS IMPOSSIBLE TO COVER NEGATIVE RANGE.')
               disp('CONSIDER CHANGING DATA TYPE FROM UNSIGNED TO SIGNED.')
               
            end

            %
            % get the "best fixed exponent"
            %   special treatment must be given when the signal extremums
            %   are both zero, in theory the "best fixed exponent" is -Inf,
            %   but this is impractical, so a default value is set for
            %   this case.
            %
            if ( ( vlo == 0 ) && ( vhi == 0 ) ) || ...
               ( ( issigned == 0 ) && ( vlo < 0 ) && ( vhi < 0 ) )
            
                bestfe = -floor(nbits/2);
                
            else

                bestfe = bestfixexp( RangeFactor * vlo, nbits, issigned );
                        
                fe     = bestfixexp( RangeFactor * vhi, nbits, issigned );
                
                if fe > bestfe
                
                    bestfe = fe;
                    
                end
           
            end

            NewOutScalingStr = ['2^(',num2str(bestfe),')'];

			if isSFData
				sf('set', sfDataID, '.fixptType.exponent', bestfe);
			else
            setParameterValue( FixPtCore{i}, 'FinalScaling', NewOutScalingStr );
			end;

            if FixPtVerbose
                disp(' ')
                disp('Output Scaling Set to ')
                disp(['    ',NewOutScalingStr])
                
                extremMat = [ vlo RangeFactor*vlo 0; vhi RangeFactor*vhi 0];
                if issigned
                    extremMat(1,3) = -1 *  2^(nbits-1)    * 2^bestfe;
                    extremMat(2,3) =      (2^(nbits-1)-1) * 2^bestfe;
                else
                    extremMat(1,3) = 0;
                    extremMat(2,3) = (2^(nbits)-1) * 2^bestfe;
                end
                disp(' ')
                disp('Comparison of Extremums of the Output Signals')
                disp('  1) Raw Extremum')
                disp('  2) Extremum after multiplication by RangeFactor')
                disp('  3) Signal range using the new scaling')
                disp('  Minimum')
                disp(extremMat(1,:))
                disp('  Maximum')
                disp(extremMat(2,:))
            end
                
        else
        
            disp(' ')
            disp('Output data type is not sfix(...) or ufix(...)')
            disp('so scaling is already set by data type.')
                                        
        end  % class == FIX
        
    end  % lock
    
end % blocks pass 2

%
% Now to process SP blocks
%

processSPBlocks(FixPtSP,FixPtVerbose,RangeFactor,topSubSystemToScale);

%
% display message that autoscaling is done
%
if FixPtVerbose
   disp(' ')
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp('% FIXED POINT BLOCKSET AUTOSCALING TOOL                               %')
   disp('% Automatic setting of radix points for unlocked fixed point outputs  %')
   disp('% is complete.                                                        %')
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end

%
% display an extra message on the existence of warnings
%
if WarningsOccurred
   disp(' ')
   disp('!!!!!!!!!!!! WARNINGS OCCURRED IN FIXED POINT AUTOSCALING !!!!!!!!!!!!!')
end


if globalVarAlreadyUsed
   FixPtTempGlobal = globalVar_OrigCopy;
else
   clear global GFIXPTDIALOG;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blockRecordOut = getWhatsAbove(blockRecordIn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  blockRecordOut = blockRecordIn;

  if ~isfield(blockRecordIn,'Parents')

    blockRecordOut.Parents = {};
  
    blockRecordOut.isUnderMaskWorkspace = {};
  
    blockRecordOut.isUnderLibraryLink = {};
  
    curBlock = blockRecordOut.Path;
    
    curRoot = bdroot(curBlock);
    
    while ~strcmp(curBlock,curRoot)
    
      blockRecordOut.Parents{end+1} = curBlock;
    
      % at this point, just determine if current block has a functional mask
      % later the value is corrected to determine if any parent has a
      % functional mask
      blockRecordOut.isUnderMaskWorkspace{end+1} = hasmask(curBlock)==2;
    
      % at this point, just determine if current block is a link
      % later the value is corrected to determine if any parent is
      % a link
      blockRecordOut.isUnderLibraryLink{end+1} = ~any(strcmp( get_param(curBlock,'LinkStatus'), {'none','inactive'} ));
  
      curBlock = get_param(curBlock,'parent');
    end
  
    isUnderLibraryLink = 0;
  
    isUnderMaskWorkspace = 0;
  
    numParent = length(blockRecordOut.Parents);
    
    for i = 1:numParent
    
      j = numParent-i+1;
      
      curUnderMaskWorkspace = blockRecordOut.isUnderMaskWorkspace{j};
      
      curUnderLink = blockRecordOut.isUnderLibraryLink{j};
      
      blockRecordOut.isUnderMaskWorkspace{j} = isUnderMaskWorkspace;
      
      blockRecordOut.isUnderLibraryLink{j} = isUnderLibraryLink;
      
      if curUnderMaskWorkspace
        isUnderMaskWorkspace = 1;
      end
      
      if curUnderLink
        isUnderLibraryLink = 1;
      end
      
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end getWhatsAbove
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blockRecordOut = getBlockParameterInfo(blockRecordIn,paramName,followToOrigin,paramRename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin < 4
    paramRename = paramName;
  end

  if nargin < 3
    followToOrigin = 1;
  end
  
  blockRecordOut = getWhatsAbove( blockRecordIn );

  if ~isfield(blockRecordOut,'Parameters')
    blockRecordOut.Parameters = [];
  end
  
  if ~isfield(blockRecordOut.Parameters,paramRename)
    blockRecordOut.Parameters.(paramRename) = [];
  end

  numParents = length(blockRecordOut.Parents);
  
  maskParamOrigin = '';
  
  paramAlias = '';
  
  isUnderLibraryLink = 0;
  
  isEditField = 0;
  
  isUnderMaskWorkspace = 0;
  
  nextParamAlias = paramName;

  % A crude rule is used to determine where the parameter originates
  %
  % The basic idea is that we look to see if 'cat' is a parameter name for 
  % the current mask.  If it is not, then we're done.  If it is we get its 
  % value, if the value is say 'dog', then we look to see if 'dog' is 
  % parameter name for the mask above.  If not, we're done.  If it is, then we
  % get the value of the parameter named 'dog', say its 'pig'.  We then look
  % to see if 'pig' is a parameter name of the mask above and so on.
  %
  % This crude rule does handle change in the parameter name from mask to
  % mask, but otherwise assumes the parameter is handed straight down.
  % This rule totally ignores anything that MaskInitialization is doing to
  % the parameter being processed.
  %   
  for i=1:numParents

     curBlock = blockRecordOut.Parents{i};
     
     if i==1 || hasmask(curBlock)==2

       dialogParams = get_param(curBlock,'DialogParameters');
       
       if isfield(dialogParams,nextParamAlias) 
                   
          maskParamOrigin = blockRecordOut.Parents{i};
          
          paramAlias = nextParamAlias;
          
          nextParamAlias = get_param(maskParamOrigin,paramAlias);

          curDialogParamInfo = dialogParams.(paramAlias);
          
          isEditField = strcmp( curDialogParamInfo.Type, 'string');
  
          isUnderLibraryLink = blockRecordOut.isUnderLibraryLink{i};
          
          isUnderMaskWorkspace = blockRecordOut.isUnderMaskWorkspace{i};
          
          if  ~isEditField || ( ~followToOrigin && ~isUnderLibraryLink )
            break;
          end        
       else
          break;
       end     
     end
  end
   
  blockRecordOut.Parameters.(paramRename).maskParamOrigin      = maskParamOrigin;
  blockRecordOut.Parameters.(paramRename).paramAlias           = paramAlias;
  blockRecordOut.Parameters.(paramRename).isUnderLibraryLink   = isUnderLibraryLink;
  blockRecordOut.Parameters.(paramRename).isEditField          = isEditField;
  blockRecordOut.Parameters.(paramRename).isUnderMaskWorkspace =  isUnderMaskWorkspace;

  if strcmp( paramRename, 'FinalScaling' )
    %
    LockScale = 'off';
    
    if ~isempty(maskParamOrigin)
      %
      % special treatment is given to 'lockscale' parameter
      %   the lock scale parameter should be taken from the same mask
      % that holds the Scaling parameter
      %
      dialogParams = get_param(maskParamOrigin,'DialogParameters');

      if isfield(dialogParams,'LockScale') 
                   
        LockScale  = get_param(maskParamOrigin,'LockScale');
      end     
    end
    blockRecordOut.Parameters.(paramRename).LockScale =  LockScale;
  end     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end getBlockParameterInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blockRecordOut = instrumentParameter( blockRecordIn, paramName, followToOrigin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin < 3
    followToOrigin = 0;
  end

  blockRecordIn_NotCell = ~iscell(blockRecordIn);
  
  if blockRecordIn_NotCell
    blockRecordOut = { blockRecordIn };
  else
    blockRecordOut = blockRecordIn;
  end

  if ~iscell(paramName)
    paramName = { paramName };
  end

  for iBlock = 1:length(blockRecordOut)
  
    curBlockRecord = blockRecordOut{iBlock};
    
    for iParam = 1:length(paramName)
    
      curParamName = paramName{iParam};
    
      if length(followToOrigin) < iParam
        curFollowToOrigin = followToOrigin(1);
      else
        curFollowToOrigin = followToOrigin(iParam);
      end
      
      if ~isfield(blockRecordOut,'Parameters') || ...
         ~isfield(curBlockRecord.Parameters,curParamName)
      
        curBlockRecord = getBlockParameterInfo(curBlockRecord,curParamName,curFollowToOrigin);
      end
      
      maskParamOrigin      = curBlockRecord.Parameters.(curParamName).maskParamOrigin;
      paramAlias           = curBlockRecord.Parameters.(curParamName).paramAlias;
      isUnderLibraryLink   = curBlockRecord.Parameters.(curParamName).isUnderLibraryLink;
      isEditField          = curBlockRecord.Parameters.(curParamName).isEditField;
      isUnderMaskWorkspace = curBlockRecord.Parameters.(curParamName).isUnderMaskWorkspace;

      if ~isempty(maskParamOrigin) && ~isempty(paramAlias)
        %
        % must have valid mask to be handled
        %
        paramStr = get_param( maskParamOrigin, paramAlias );
        
        if isEditField
      
          if isUnderMaskWorkspace
          
            if ~isUnderLibraryLink
              %
              % when under a masked, instrument only if not under a library links
              %
              % set up edit field so that parameter value can be stolen during a model update
              %    
              curBlockRecord.Parameters.(curParamName).paramStr = paramStr;
              
              curPath = curBlockRecord.Path;
              
              curPathClean = strrep(curPath,sprintf('\n'),'\n');
              
              curPathClean = ['sprintf(''',curPathClean,''')'];
    
              set_param( maskParamOrigin, paramAlias, ['stealparameter(',curPathClean,',''',curParamName,''',', paramStr, ')'])
            end
          else
            %
            % get parameter value via immediate evaluation
            %    
            paramValue = evalin('base',paramStr);
            
            curBlockRecord.Parameters.(curParamName).paramValue = paramValue;    
          end
        else
          paramValue = paramStr;
          curBlockRecord.Parameters.(curParamName).paramValue = paramValue;    
        end
      else
        %
        % not a mask parameter so see if it is an object parameter
        %
        objectParameterNames = fieldnames(get_param(curBlockRecord.Parents{1},'objectparameters'));
        
        if any(strcmp(curParamName,objectParameterNames))
        
          paramValue = get_param(curBlockRecord.Parents{1},curParamName);
          
          curBlockRecord.Parameters.(curParamName).paramValue = paramValue;              
        end
      end
    end
    
    % save changes to block record
    blockRecordOut{iBlock} = curBlockRecord;
  end

  if blockRecordIn_NotCell
    blockRecordOut = blockRecordOut{1};
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end instrumentParameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeAllInstrumentation( blockRecord )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  for iBlock = 1:length(blockRecord)
  
    curBlockRecord = blockRecord{iBlock};
    
    if isfield(curBlockRecord,'Parameters')
    
      paramName = fieldnames(curBlockRecord.Parameters);
      
      for iParam = 1:length(paramName)
      
        curParamName = paramName{iParam};
        
        curParamRecord = curBlockRecord.Parameters.(curParamName);
        
        if isfield( curParamRecord, 'paramStr');
        
          maskParamOrigin    = curBlockRecord.Parameters.(curParamName).maskParamOrigin;
          paramAlias         = curBlockRecord.Parameters.(curParamName).paramAlias;
          paramStr           = curBlockRecord.Parameters.(curParamName).paramStr;
          
          set_param( maskParamOrigin, paramAlias, paramStr);
        end
      end
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end removeAllInstrumentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function paramValue = getParamOrDefault(blockRecord,paramName,defaultParamValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  paramValue = defaultParamValue;

  if isfield(blockRecord,'Parameters')
  
    curParameterRecords = blockRecord.Parameters;
    
    if isfield(curParameterRecords,paramName)
    
      curParamRec = curParameterRecords.(paramName);
      
      if isfield(curParamRec,'paramValue')
      
         paramValue = curParamRec.paramValue;
      end
    end
  end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end getParamOrDefault
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iFound = findBlockRecord( curBlock )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global FixPtTempGlobal

len = length(FixPtTempGlobal);

iFound = 0;

for i=1:len
  if strcmp( FixPtTempGlobal{i}.Path, curBlock ) || ...
     strcmp( FixPtTempGlobal{i}.Path, strrep( curBlock, sprintf('\n'),' ') )
    iFound = i;
    break;
  end
end

if ~iFound
  FixPtTempGlobal{end+1}.Path = curBlock;
  iFound = len+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end findBlockRecord
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setParameterValue( blockRecord, paramName, paramValueStrNew )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if blockRecord.Parameters.(paramName).isUnderLibraryLink
    %
    % don't set values on library links
    %
    return;
  end

  maskParamOrigin = blockRecord.Parameters.(paramName).maskParamOrigin;
  paramAlias      = blockRecord.Parameters.(paramName).paramAlias;  
  
  set_param( maskParamOrigin, paramAlias, paramValueStrNew );
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end setParameterValue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isSettable = parameterIsSettable( blockRecord, paramName )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  isSettable = 0;

  if isfield(blockRecord,'Parameters')
  
    curParameterRecords = blockRecord.Parameters;
    
    if isfield(curParameterRecords,paramName)
    
    curParamRec = curParameterRecords.(paramName);
      
      maskParamOrigin    = getFieldOrDefault(curParamRec,'maskParamOrigin','');

      paramAlias         = getFieldOrDefault(curParamRec,'paramAlias','');

      isUnderLibraryLink = getFieldOrDefault(curParamRec,'isUnderLibraryLink',1);

      if ~isempty(maskParamOrigin) && ~isempty(paramAlias) && ~isUnderLibraryLink
      
        isSettable = 1;
      end
    end
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end parameterIsSettable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function fieldValue = getFieldOrDefault(inStruct,fieldName,defaultFieldValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  fieldValue = defaultFieldValue;

  if ~iscell(fieldName)
    fieldName = { fieldName };
  end
  
  curStruct = inStruct;
  
  for i = 1:length(fieldName)
  
    curFieldName = fieldName{i};
    
    if ~isfield( curStruct, curFieldName )
      %
      % return early and use default
      %
      return    
    end
  
    curStruct = curStruct.(curFieldName);
  end
  
  fieldValue = curStruct;
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end getFieldOrDefault
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function FixPtTempGlobal = shareDTDuplicateMinMax(CurrentSystem)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  global FixPtTempGlobal

  %
  % find data type duplicate blocks
  %   find the worst case min and max for each connected signal
  %   force the other signals to use that min and max. 
  %
  libblk_name = fixptlibname({'Data','Type','Duplicate'},'block');
  
  libblk_type = get_param(libblk_name,'MaskType');
  
  libblk_instances = find_system(CurrentSystem,'FollowLinks','on','LookUnderMasks','all','MaskType',libblk_type);
  
  nInstance = length(libblk_instances);
  
  % A group of signals can be "locked together" via one OR MORE data type
  % duplicate blocks.  The one case is easy, but the multiple case has a
  % pitfall.  In the multiple case, spreading the worst case min max 
  % across all inputs to that block will not propagate the true worst case
  % to all the signals "locked together" unless a "lucky ordering" occurred. 
  % To solve this issue, propagation process will be repeated until
  % nobody changes.  
  %   To reduce the likelihood that some error throws us into an infinite while
  % loop, looping is limited by the number of dtprop blocks in the model.
  %
  somebodyChanged = 1;
  
  iIterate = 0;
  
  while somebodyChanged && iIterate < nInstance
  
    somebodyChanged = 0;
    
    iIterate = iIterate + 1;
    
    for iInstance = 1:nInstance
    
      curBlk = libblk_instances{iInstance};
      
      hPorts = get_param(curBlk,'PortHandles');
  
      nInports = length(hPorts.Inport);
      
      dtdup_min =  realmax;
      dtdup_max = -realmax;
    
      % first pass:  determine worst case min max
      % second pass: overwrite min maxs to worst case
      %
      for iPass = 1:2
      
        for iInport = 1:nInports
                    
          hInportCur = hPorts.Inport(iInport);
          interface  = get_param(hInportCur, 'UDDObject');
          hSource    = interface.getActualSrc;
           
          sourceBlk = get_param(hSource(1),'Parent');
                
          iFound = findBlockRecord( sourceBlk );
          
          minValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MinValue', realmax);
          
          maxValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MaxValue',-realmax);
          
          if iPass == 1
            if minValue < dtdup_min
            
              dtdup_min = minValue;
            end
            
            if maxValue > dtdup_max
            
              dtdup_max = maxValue;
            end
          else
            if isfield(FixPtTempGlobal{iFound},'MinValue') && minValue > dtdup_min
            
              somebodyChanged = 1;
              
              FixPtTempGlobal{iFound}.MinValue = dtdup_min;
            end
            
            if isfield(FixPtTempGlobal{iFound},'MaxValue') && maxValue < dtdup_max
            
              somebodyChanged = 1;
                          
              FixPtTempGlobal{iFound}.MaxValue = dtdup_max;
            end        
          end
        end    
      end  
    end
  end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end shareDTDuplicateMinMax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function FixPtTempGlobal = shareBreakpointMinMax(CurrentSystem)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  global FixPtTempGlobal

  libblk_look1D = fixptlibname({'Look','Up'        },'block');

  libblk_look2D = fixptlibname({'Look','Up','2','D'},'block');

  for iCase = 1:3
    %
    % find data type duplicate blocks
    %   find the worst case min and max for each connected signal
    %   force the other signals to use that min and max. 
    %
    
    switch iCase
    
    case 1
    
      libblk_name = libblk_look1D;
      paramName   = 'InputValues';
      portNum     = 1;
    
    case 2
    
      libblk_name = libblk_look2D;
      paramName   = 'RowIndex';
      portNum     = 1;
    
    case 3
    
      libblk_name = libblk_look2D;
      paramName   = 'ColumnIndex';
      portNum     = 2;
    
    end
    if strcmp(get_param(libblk_name, 'Mask'), 'on');
      curKind = 'MaskType';
    else
      curKind = 'BlockType';
    end
    libblk_type = get_param(libblk_name,curKind);
    
    libblk_instances = find_system(CurrentSystem,'FollowLinks','on','LookUnderMasks','all',curKind,libblk_type);
    
    nInstance = length(libblk_instances);
    
    for iInstance = 1:nInstance
    
      curBlk = libblk_instances{iInstance};
      
      hPorts = get_param(curBlk,'PortHandles');
  
      hInportCur = hPorts.Inport(portNum);
      
      interface  = get_param(hInportCur, 'UDDObject');
      hSource    = interface.getActualSrc;
       
      sourceBlk = get_param(hSource(1),'Parent');
            
      iFound = findBlockRecord( sourceBlk );
      
      minValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MinValue', realmax);
      
      maxValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MaxValue',-realmax);
      
      iFoundBreak = findBlockRecord( curBlk );
      
      breakpoints = getParamOrDefault(FixPtTempGlobal{iFoundBreak},paramName,[]);
      
      if ~isempty(breakpoints)
      
        breakpoints_min = min(min(breakpoints));
        breakpoints_max = max(max(breakpoints));
      
        if minValue > breakpoints_min
        
          FixPtTempGlobal{iFound}.MinValue = breakpoints_min;
        end
        
        if maxValue < breakpoints_max
                      
          FixPtTempGlobal{iFound}.MaxValue = breakpoints_max;
        end                
      end
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end shareBreakpointMinMax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function FixPtTempGlobal = connectDTPropagation(CurrentSystem)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  global FixPtTempGlobal

  libblk_name = fixptlibname({'Data','Type', 'Propag'},'block');

  libblk_type = get_param(libblk_name,'MaskType');
  
  libblk_instances = find_system(CurrentSystem,'LookUnderMasks','all','MaskType',libblk_type);
  
  nInstance = length(libblk_instances);
  
  for iInstance = 1:nInstance
  
    curBlk = libblk_instances{iInstance};
    
    hPorts = get_param(curBlk,'PortHandles');

    hInportCur = hPorts.Inport(3);
    interface  = get_param(hInportCur, 'UDDObject');
    hSource    = interface.getActualSrc;
     
    sourceBlk = get_param(hSource(1),'Parent');
          
    iFound = findBlockRecord( sourceBlk );
    
    minValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MinValue', realmax);
    
    maxValue = getFieldOrDefault(FixPtTempGlobal{iFound},'MaxValue',-realmax);
    
    iFoundProp = findBlockRecord( curBlk );

    minValueProp = getFieldOrDefault(FixPtTempGlobal{iFoundProp},'MinValue', realmax);
    
    maxValueProp = getFieldOrDefault(FixPtTempGlobal{iFoundProp},'MaxValue',-realmax);
        
    if minValueProp > minValue
    
      FixPtTempGlobal{iFoundProp}.MinValue = minValue;
    end
    
    if maxValueProp < maxValue
                  
      FixPtTempGlobal{iFoundProp}.MaxValue = maxValue;
    end                
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end connectDTPropagation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isSame = isSameBlockType(curBlock,keyWordCell)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fixptLibBlk = fixptlibname(keyWordCell,'block');

if strcmp(get_param(fixptLibBlk, 'Mask'), 'on');
  curKind = 'MaskType';
else
  curKind = 'BlockType';
end

isSame = strcmp(get_param(curBlock,curKind),get_param(fixptLibBlk,curKind));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end isSameBlockType
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function storeGlobalFixPtSimRanges()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The autoscaling process can cause the Min-Max-Overflow logging structure
% to be overridden with junk.  Store a copy for subsequent restoration.
%
if any(strcmp('FixPtSimRanges',who('global')))
  
  global FixPtSimRanges
  global pre_autoscale_FixPtSimRanges
  pre_autoscale_FixPtSimRanges = FixPtSimRanges;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end storeGlobalFixPtSimRanges()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restoreGlobalFixPtSimRanges()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The autoscaling process can cause the Min-Max-Overflow logging structure
% to be overridden with junk.  Restore the original structure.
%
if any(strcmp('pre_autoscale_FixPtSimRanges',who('global')))
  
  global FixPtSimRanges
  global pre_autoscale_FixPtSimRanges
  FixPtSimRanges = pre_autoscale_FixPtSimRanges;
  clear global pre_autoscale_FixPtSimRanges
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end restoreGlobalFixPtSimRanges()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [coreRecords,spRecords] = splitBlockRecords(blockRecords)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Split the block records into basic (core) blocks and SP Blockset blocks,
% which need different treatment
% 
notCell = ~iscell(blockRecords);

if notCell
  blockRecords = { blockRecords };
end

[CORE_BLOCK,SP_OUTPUT_BLOCK,SP_NON_OUTPUT_BLOCK] = deal(0,1,2);

coreRecords = {};
spRecords = {};
len = length(blockRecords);
for ii = 1 : len
  % see if current block is an SP block
  isSP = 0;
  if isfield(blockRecords{ii},'Path')
    obj = get_param(blockRecords{ii}.Path,'object');
    fields = fieldnames(obj);
    % all relevant SP blocks have at least one of {prodOutputMode,accumMode,
    % outputMode} - and no core blocks use these fields
    if any(strcmp(fields,'prodOutputMode')) || ...
          any(strcmp(fields,'accumMode')) || ...
          any(strcmp(fields,'outputMode'))
      % it's an SP block
      isSP = 1;
      if isfield(blockRecords{ii},'SignalName') && strcmp(blockRecords{ii}.SignalName,'Output')
        blockRecords{ii}.BlockCategory = SP_OUTPUT_BLOCK;
      else
        blockRecords{ii}.BlockCategory = SP_NON_OUTPUT_BLOCK;
      end
    end
  end
  if isSP
    spRecords{end+1} = blockRecords{ii};
  else
    blockRecords{ii}.BlockCategory = CORE_BLOCK;
    coreRecords{end+1} = blockRecords{ii};
  end    
end

if notCell
  if isempty(coreRecords)
    coreRecords = [];
  else
    coreRecords = coreRecords{1};
  end
  if isempty(spRecords)
    spRecords = [];
  else
    spRecords = spRecords{1};
  end
end

%disp(['found ' num2str(length(spRecords)) ' sp records'])
%disp(['found ' num2str(length(coreRecords)) ' core records'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end splitBlockRecords
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outputRecords,nonOutputRecords] = splitOutputBlockRecords(blockRecords)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
notCell = ~iscell(blockRecords);

if notCell
  blockRecords = { blockRecords };
end

SP_NON_OUTPUT_BLOCK = 2;

outputRecords = {};
nonOutputRecords = {};
len = length(blockRecords);
for ii = 1 : len
  if isfield(blockRecords{ii},'BlockCategory') && ...
        blockRecords{ii}.BlockCategory == SP_NON_OUTPUT_BLOCK
    nonOutputRecords{end+1} = blockRecords{ii};
  else
    outputRecords{end+1} = blockRecords{ii};
  end
end

if notCell
  if isempty(outputRecords)
    outputRecords = [];
  else
    outputRecords = outputRecords{1};
  end
  if isempty(nonOutputRecords)
    nonOutputRecords = [];
  else
    nonOutputRecords = nonOutputRecords{1};
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end splitOutputBlockRecords
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processSPBlocks(blockRecords,FixPtVerbose,RangeFactor,topSubSystemToScale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
followToOrigin_YES = 1;
followToOrigin_NO  = 0;

% 
% set the new scalings
%
nblocks = length(blockRecords);

for i = 1:nblocks

  unknownParam = 0;
  
  switch blockRecords{i}.SignalName
   case 'Accumulator'
    modeStr = 'accumMode';
    wlStr   = 'accumWordLength';
    flStr   = 'accumFracLength';
   case 'Product output'
    modeStr = 'prodOutputMode';
    wlStr   = 'prodOutputWordLength';
    flStr   = 'prodOutputFracLength';
   case 'State'
    modeStr = 'memoryMode';
    wlStr   = 'memoryWordLength';
    flStr   = 'memoryFracLength';
   case 'Output'
    modeStr = 'outputMode';
    wlStr   = 'outputWordLength';
    flStr   = 'outputFracLength';
   otherwise
    if FixPtVerbose
      disp(' ')
      disp('BLOCK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
      disp(' ')
      disp([blockRecords{i}.Path ' : ' blockRecords{i}.SignalName]);
      disp(' ')
      disp('  Block parameter can''t be autoscaled.')
      disp(['    Autoscaling of block''s "' blockRecords{i}.SignalName '" parameter is not supported.'])
    end
    continue;
  end
  
  FinalScalingName = flStr;
    
  blockRecords{i} = getBlockParameterInfo(blockRecords{i}, FinalScalingName, followToOrigin_YES, 'FinalScaling');      
  
  minValue = getFieldOrDefault(blockRecords{i},'MinValue', Inf);
  maxValue = getFieldOrDefault(blockRecords{i},'MaxValue',-Inf);
  
  illogicalMinMax = minValue > maxValue;
  
  Locked    =  strcmp('on', getFieldOrDefault(blockRecords{i},{'Parameters','FinalScaling','LockScale'},'off') );
  
  Inherited = ~any(strcmp({'Binary point scaling','Slope and bias scaling','User-defined'}, ...
                          getParamOrDefault(blockRecords{i},modeStr,'')));
  
  outScalingSettable = parameterIsSettable( blockRecords{i}, 'FinalScaling' );
  
  hasDataTypeField =   isfield(blockRecords{i},'Parameters') && ...
      ( ...
          ( ...
              isfield(blockRecords{i}.Parameters,wlStr) && ...
              isfield(blockRecords{i}.Parameters.(wlStr),'paramValue') ...
              ) ...
          );

  %
  % is block subsystem to be scaled?
  %
  notInTopSubSystem = 1;
  
  curParent = get_param(blockRecords{i}.Path,'Parent');
  
  while ~isempty(curParent)
    
    if strcmp(curParent,topSubSystemToScale)
      
      notInTopSubSystem = 0;
      break;
    end
    
    curParent = get_param(curParent,'Parent');
  end

  if illogicalMinMax || Locked || Inherited || ~outScalingSettable || notInTopSubSystem || ~hasDataTypeField || unknownParam
    doScaling = 0;
  else
    doScaling = 1;
  end

  if FixPtVerbose
    disp(' ')
    disp('BLOCK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(' ')
    disp([blockRecords{i}.Path ' : ' blockRecords{i}.SignalName]);
    
    if ~doScaling
      disp(' ')
      disp('  Block parameter can''t be autoscaled.')
    end
    
    if notInTopSubSystem
      disp('    Block is outside subsystem to be scaled.')
    end
    
    if illogicalMinMax
      disp('    Block''s logged minimum and maximum are not logical.')
      disp('      Block was not configured to log min max data, or ')
      disp('      block was in a subsystem that was never trigger or enabled.')
    end
    
    if Locked
      disp('    Block''s scaling is locked.')
    end
    
    if Inherited
      disp('    Block''s data type and/or scaling is inherited.')
    end
    
    if ~outScalingSettable
      disp('    Block''s scaling is not settable.')
    end
    
    if ~hasDataTypeField
      disp('    Block does not have expected data type field.')
    end
  end
   
  %
  % only processes blocks whose scaling is NOT LOCKED
  %
  if doScaling
       
    curWL = blockRecords{i}.Parameters.(wlStr).paramValue;
    % xxx - TBD - support unsigned!
    curOutDataType = sfix(curWL);

    if FixPtVerbose
      disp(' ')
      disp([blockRecords{i}.SignalName ' Data Type'])
      disp(curOutDataType)
    end

    %
    % initialize extremums
    %
    vlo =  Inf;
    vhi = -Inf;

    %
    % update minimum as needed
    %
    v = minValue;
    if v < vlo
      vlo = v;
    end
    
    %
    % update maximum as needed
    %
    v = maxValue;
    if v > vhi
      vhi = v;
    end
            
    %
    % get storage class info
    %
    nbits = curWL; %curOutDataType.MantBits;
    
    issigned = curOutDataType.IsSigned;
    
    %
    % deal with negative values for unsigned case
    %
    if ( issigned == 0 ) && ( vlo < 0 )   
      
      WarningsOccurred = 1;
      
      disp(' ')
      disp('WARNING: MINIMUM IS NEGATIVE, BUT DATA TYPE IS UNSIGNED.')
      disp('IT IS IMPOSSIBLE TO COVER NEGATIVE RANGE.')
      disp('CONSIDER CHANGING DATA TYPE FROM UNSIGNED TO SIGNED.')
      
    end
    
    %
    % get the "best fixed exponent"
    %   special treatment must be given when the signal extremums
    %   are both zero, in theory the "best fixed exponent" is -Inf,
    %   but this is impractical, so a default value is set for
    %   this case.
    %
    if ( ( vlo == 0 ) && ( vhi == 0 ) ) || ...
                ( ( issigned == 0 ) && ( vlo < 0 ) && ( vhi < 0 ) )
      
      bestfe = -floor(nbits/2);
      
    else
      bestfe = bestfixexp( RangeFactor * vlo, nbits, issigned );
      fe     = bestfixexp( RangeFactor * vhi, nbits, issigned );
      
      if fe > bestfe
        bestfe = fe;
      end
    end

    NewOutScalingStr = num2str(-bestfe);

    setParameterValue( blockRecords{i}, 'FinalScaling', NewOutScalingStr );

    if FixPtVerbose
      disp(' ')
      disp([blockRecords{i}.SignalName ' Scaling Set to '])
      disp(['    ',NewOutScalingStr])
      
      extremMat = [ vlo RangeFactor*vlo 0; vhi RangeFactor*vhi 0];
      if issigned
        extremMat(1,3) = -1 *  2^(nbits-1)    * 2^bestfe;
        extremMat(2,3) =      (2^(nbits-1)-1) * 2^bestfe;
      else
        extremMat(1,3) = 0;
        extremMat(2,3) = (2^(nbits)-1) * 2^bestfe;
      end
      disp(' ')
      disp('Comparison of Extremums of the Output Signals')
      disp('  1) Raw Extremum')
      disp('  2) Extremum after multiplication by RangeFactor')
      disp('  3) Signal range using the new scaling')
      disp('  Minimum')
      disp(extremMat(1,:))
      disp('  Maximum')
      disp(extremMat(2,:))
    end
    
  end  % lock
  
end % blocks pass 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end processSPBlocks(blockRecords)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
