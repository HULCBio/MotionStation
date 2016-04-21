function nnsound(y,fs)
%NNSOUND Turn Neural Network Design sounds on and off.
%
%  NNSOUND OFF turns off demo sounds.
%    Use this to avoid annoying co-workers and to speed up
%    demos with lots of sound.
%
%  NNSOUND ON turns them back on.
%    Use this when you to experience quadraphonic digitally
%    enhanced audio entertainment and you don't care who
%    knows it.
%
%  Regardless of the settings described above, sound is always
%  off for the Student Edition of MATLAB.

% First Version, 8-31-95.
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.8 $

%==================================================================

global NNDSNDFLAG
if (isempty(NNDSNDFLAG) & isunix) 
   NNDSNDFLAG='off';
end;
if nargin == 1
  fs = 8192;
end
drawnow;pause(0);
if isstr(y)
  y = lower(y);
  if strcmp(y,'off')
    NNDSNDFLAG = 'off';
  elseif strcmp(y,'on')
    NNDSNDFLAG = 'on';
  end
  
elseif ~strcmp(NNDSNDFLAG,'off') & ~nnstuded
   c = computer;
   if strcmp(c,'SUN4') | strcmp(c,'SOL2') | strcmp(c,'SGI') | ...
         strcmp(c,'HPUX') | strcmp(c,'HP700') | ...
         strcmp(c(1:3),'MAC') | strcmp(c,'NEXT') | strcmp(c,'SGI') | ...
         strcmp(c(1:2),'PC')
      success=1;
      tic;
      try, pause(0),sound(y,fs), catch, pause(0);success=0; end
      if success
         wait=(length(y)/fs)+.1;
         while (toc<wait | toc>10) end;
      end;
   end         
drawnow; pause(0);   
end

