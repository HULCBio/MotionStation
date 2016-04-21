function varargout = dspblkperiodogram(action)
% DSPBLKPERIODOGRAM Mask dynamic dialog function for Periodogram spectrum analysis block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:55:28 $ $Revision: 1.8 $

blk = gcb;
if nargin==0, action = 'dynamic'; end

switch action
case 'dynamic'
   % Execute dynamic dialogs      
   
   % Determine window popup setting, and get all dialog visibilities:
   win = lower(get_param(blk,'wintype'));
   ena_orig = get_param(blk,'maskenables');
   ena = ena_orig;
   
   % Determine whether Stopband, Beta, and Window Sampling are visible:
   iRipple = 4; isCheby  = strcmp(win,'chebyshev');
   iBeta   = 5; isKaiser = strcmp(win,'kaiser');
   iWSamp  = 6; isGenCos = any(strcmp(win,{'hamming','hann','hanning','blackman'}));
   
   % Map true/false to off/on strings, and place into visibilities array:
   enaopt = {'off','on'};
   ena([iRipple iBeta iWSamp]) = enaopt([isCheby isKaiser isGenCos]+1);
   if ~isequal(ena,ena_orig),
      % Only update if a change was really made:
      set_param(blk,'maskenables',ena);
   end
   
case 'icon'
   d = 0.1; xe=4; x=-xe:d:xe;
   y = ones(size(x)); i=find(x); y(i)=sin(pi*x(i))./(pi*x(i));
   y = abs(y).^(0.75);
   
   varargout = {x,y,xe};
   
   % Update underlying blocks:
   wintype = get_param(blk,'wintype');
   winsamp = get_param(blk,'winsamp');
   set_param([blk '/Window'],'winsamp',winsamp,'wintype',wintype);
end

% [EOF] dspblkperiodogram.m
