function addchar(this,CharIdentifier,dataClass,viewClass,varargin)
%ADDCHAR  Adds specified characteristics to all waveforms in a plot.
%
%   ADDCHAR(PLOT,charName,dataClassName,viewClassName) adds the characteristic
%   with identifier charName to all waveform's in the plot PLOT.  The strings
%   dataClassName and viewClassName specify the data and view classes used to 
%   build the charcateristic.
%
%   ADDCHAR(PLOT,charName,dataClassName,viewClassName,'Property1',Value1,...)
%   further specifies initial settings for the characteristic (@wavechar 
%   properties).
%
%   Note that the new characteristic is added only where it does not already
%   exist (based on the identifier charName).
 
%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:10 $
 
% Add characteristic to each @waveform (where doesn't already exist)
for wf = allwaves(this)'
   % Look for characteristic with matching signature
   wfChar = wf.Characteristics(strcmpi(get(wf.Characteristics,'Identifier'), ...
      CharIdentifier));
   % Create new instance if no match found
   if isempty(wfChar)
      try
         % RE: Creation may fail due to size incompatibility, cf. stability
         %     margins on plot with mix of SISO and MIMO systems
         wfChar = wf.addchar(CharIdentifier,dataClass,viewClass);   
         syncprefs(wfChar.Data, this.Preferences); % initialize parameters
      end
   end
   % Additional settings
   set(wfChar,varargin{:});
end

% Redraw
draw(this)
