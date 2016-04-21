function mergedranges = mergefixptsimranges(newranges,oldranges)
%MERGEFIXPTSIMRANGES is for internal use only by the Fixed Point Blockset

% merge max and min values from last Fixed Point Simulation

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.9.4.3 $  
% $Date: 2004/04/15 00:00:16 $

if ~iscell(newranges)
    newranges = { newranges };
end
  
lenNew = length(newranges);
lenOld = length(oldranges);

if lenOld == 0
    mergedranges = newranges;
    return;
end

mergedranges = oldranges;

for iNew = 1:lenNew

  for iMerge = 1:lenOld
    
    pathMatch = 0;
        
    if strcmp(newranges{iNew}.Path,mergedranges{iMerge}.Path) && ...
       isfield( newranges{iNew},'SignalName') == isfield( mergedranges{iMerge}, 'SignalName' )
      
      if isfield( newranges{iNew},'SignalName')
        if ~strcmp( newranges{iNew}.SignalName, mergedranges{iMerge}.SignalName )
          continue
        end
      end

      if isfield(newranges{iNew},'MinValue')
        
        if ~isfield(mergedranges{iMerge},'MinValue') || ...
              newranges{iNew}.MinValue < mergedranges{iMerge}.MinValue
          
          mergedranges{iMerge}.MinValue  = newranges{iNew}.MinValue;
        end
      end
      
      if isfield(newranges{iNew},'MaxValue')
        
        if ~isfield(mergedranges{iMerge},'MaxValue') || ...
              newranges{iNew}.MaxValue > mergedranges{iMerge}.MaxValue
          
          mergedranges{iMerge}.MaxValue  = newranges{iNew}.MaxValue;
        end
      end
      
      if isfield(newranges{iNew},'OverflowOccurred')
        
        if isfield(mergedranges{iMerge},'OverflowOccurred')
          
          mergedranges{iMerge}.OverflowOccurred  = newranges{iNew}.OverflowOccurred + mergedranges{iMerge}.OverflowOccurred;
        else
          mergedranges{iMerge}.OverflowOccurred  = newranges{iNew}.OverflowOccurred;                
        end
      end
      
      if isfield(newranges{iNew},'SaturationOccurred')
        
        if isfield(mergedranges{iMerge},'SaturationOccurred')
          
          mergedranges{iMerge}.SaturationOccurred  = newranges{iNew}.SaturationOccurred + mergedranges{iMerge}.SaturationOccurred;
        else
          mergedranges{iMerge}.SaturationOccurred  = newranges{iNew}.SaturationOccurred;                
        end
      end
      
      if isfield(newranges{iNew},'ParameterSaturationOccurred')
        
        if isfield(mergedranges{iMerge},'ParameterSaturationOccurred')
          
          mergedranges{iMerge}.ParameterSaturationOccurred  = newranges{iNew}.ParameterSaturationOccurred + mergedranges{iMerge}.ParameterSaturationOccurred;
        else
          mergedranges{iMerge}.ParameterSaturationOccurred  = newranges{iNew}.ParameterSaturationOccurred;                
        end
      end
      
      if isfield(newranges{iNew},'DivisionByZeroOccurred')
        
        if isfield(mergedranges{iMerge},'DivisionByZeroOccurred')
          
          mergedranges{iMerge}.DivisionByZeroOccurred  = newranges{iNew}.DivisionByZeroOccurred + mergedranges{iMerge}.DivisionByZeroOccurred;
        else
          mergedranges{iMerge}.DivisionByZeroOccurred  = newranges{iNew}.DivisionByZeroOccurred;                
        end
      end
      
      pathMatch = 1;
      break;
      
    end % path match
    
  end  % iMerge
    
  if pathMatch == 0
    l = length(mergedranges)+1;
    mergedranges{l} = newranges{iNew};
  end
    
end  % iNew
