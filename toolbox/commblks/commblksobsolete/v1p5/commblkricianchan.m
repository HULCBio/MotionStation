function varargout = commblkricianchan(block,varargin)
% COMMBLKRICIANCHAN Rician channel helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:44:42 $

% --- Set the normalize gain off
targetBlk = [block '/Multipath Fading Channel'];

if(strcmp(get_param(targetBlk,'normGain'),'on'))
   set_param(targetBlk,'normGain','off');
end;


