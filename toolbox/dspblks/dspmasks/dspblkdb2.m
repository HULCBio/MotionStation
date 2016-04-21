function varargout = dspblkdb2(action)
% DSPBLKDB2 Mask helper function for dB block.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:00:38 $

if nargin==0, action = 'dynamic'; end

blk=gcb;
isAmp =  strcmp(get_param(blk,'intype'),'Amplitude');


switch action
   
   case 'checkparam'
   
      R = get_param(blk,'R');
      if str2num(R) <= 0
         error('Load resistance must be greater than zero.');
      end
   
      
   case 'dynamic'
      % Enable the Elements edit dialog:
      ena = get_param(blk,'MaskEnables');
      if isAmp==1,
         new_ena = 'on';
      else
         new_ena = 'off';
      end
      
      % Don't dirty model until absolutely necessary:
      if ~strcmp(ena{3},new_ena),
         ena{3} = new_ena;
         set_param(blk,'MaskEnables',ena);                                                                                                                                                      
      end
      
   case 'init'
      
      dBtype = get_param(blk,'dBtype');
      
      if isAmp == 1
         R = get_param(blk,'R');
         if str2num(R) <= 0
            str = sprintf('%s \n %s','Invalid','resistance.');
         else
            str = sprintf('%s \n (%s ohm)',dBtype,R);            
         end
      else
         str = dBtype;
      end
             
      varargout{1} = str;
      fuzz  =  get_param(blk,'fuzz');
      if strcmp(fuzz,'on')
        varargout{2} = eps;
      else
        varargout{2} = 0.0;
      end
      
      if strcmp(get_param(blk,'dBtype'),'dBm');
         % Decibels relative to 1 mW (milliWatt)
         % Set dBval (offset under mask)
         varargout{3} = 30.0;
      else
         varargout{3} = 0.0;
      end             
      
   case 'update'
      
      %%%%%%%%% Input signal popup menu %%%%%%%
      opts(1).name = 'Magsq'; 
      opts(1).src  = 'built-in/Math'; 
      opts(1).args = {'Operator','magnitude^2'};
      
      opts(2).name = 'R'; 
      opts(2).src  = 'built-in/Gain'; 
      opts(2).args = {'Gain','1/R'};
      
      if isAmp == 1
         % AMPLITUDE: Add the magsq and 1/R blocks  
         replace = 0;
      else
         % POWER: Remove the magsq and 1/R blocks
         replace = 1;         
      end   
      dspskipblk(blk,opts, replace);
   
   otherwise
      error('unhandled case');
end

% [EOF] dspblkdb2.m
