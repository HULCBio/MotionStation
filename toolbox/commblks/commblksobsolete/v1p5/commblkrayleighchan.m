function varargout = commblkrayleighchan(block,varargin)
% COMMBLKRAYLEIGHCHAN Rayleigh channel helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:44:39 $

% --- Set the normalize gain mode if required
targetBlk = [block '/Multipath Fading Channel'];

if(strcmp(get_param(block,'normGain'),'on'))
   if(strcmp(get_param(targetBlk,'normGain'),'off'))
      set_param(targetBlk,'normGain','on');
   end;
else
   if(strcmp(get_param(targetBlk,'normGain'),'on'))
      set_param(targetBlk,'normGain','off');
   end;
end;
