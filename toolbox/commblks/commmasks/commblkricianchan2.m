function varargout = commblkricianchan2(block,varargin)
% COMMBLKRICIANCHAN Rician channel helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/24 02:00:55 $

% --- Set the normalize gain off
targetBlk = [block '/Multipath Fading Channel'];

if(strcmp(get_param(targetBlk,'normGain'),'on'))
   set_param(targetBlk,'normGain','off');
end;


