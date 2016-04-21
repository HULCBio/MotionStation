function addchar(this,CharIdentifier,dataClass,outputviewClass,inputviewClass,varargin)
%ADDCHAR  Adds specified characteristics to all waveforms in a plot.
%
%   ADDCHAR(PLOT,charName,dataClassName,outputviewClassName,inputviewClass) adds  
%   the characteristic with identifier charName to all waveform's in the simplot PLOT.  
%   The strings dataClassName, viewClassName, and inputviewClass specify the data,
%   output view, and input view classes used to build the charcateristic.
%
%   ADDCHAR(PLOT,charName,...,'Property1',Value1,...) further specifies initial 
%   settings for the characteristic (@wavechar properties).
%
%   Note that the new characteristic is added only where it does not already
%   exist (based on the identifier charName).
 
%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:49 $
 
% Add characteristic to each @waveform (where doesn't already exist)
for r = this.Responses'
   % Look for characteristic with matching signature
   rChar = r.Characteristics(strcmpi(get(r.Characteristics,'Identifier'), ...
      CharIdentifier));
   % Create new instance if no match found
   if isempty(rChar)
      rChar = r.addchar(CharIdentifier,dataClass,outputviewClass);   
      syncprefs(rChar.Data, this.Preferences); % initialize parameters
   end
   % Additional settings
   set(rChar,varargin{:})
end

% Add characteristic to sim. input view if explicitly requested
if ~isempty(inputviewClass)
   for wf = this.Input'
      wfChar = wf.Characteristics(strcmpi(get(wf.Characteristics,'Identifier'),...
         CharIdentifier));
      if isempty(wfChar)
         % Create response characteristics
         wfChar = wf.addchar(CharIdentifier,dataClass,inputviewClass);   
         syncprefs(wfChar.Data, this.Preferences); % initialize parameters
      end
      % Additional settings
      set(wfChar,varargin{:})
   end
end

% Redraw
draw(this)