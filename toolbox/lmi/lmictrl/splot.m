% splot(sys,choice,xrange)         (continuous-time)
% splot(sys,T,choice,xrange)       (discrete-time)
%
% General-purpose function for plotting the frequency or time
% response of the system SYS
%
% Input:
%   SYS         SYSTEM matrix (see LTISYS)
%   CHOICE      string specifying what should be plotted
%                  'bo'  :   Bode plot
%                  'sv'  :   singular value plot
%                  'ny'  :   Nyquist plot (SISO)
%                  'li'  :   Lin-log Nyquist plot (SISO)
%                  'ni'  :   Black/Nichols chart (SISO)
%
%                  'st'  :   step response
%                  'im'  :   impulse response
%                  'sq'  :   response to a square wave
%                  'si'  :   response to a sine wave
%   XRANGE      user-specified vector of frequencies or
%               times (optional).  For options 'sq' and 'si',
%               XRANGE is simply the period of the input
%               signal.
%   T           sampling period in seconds (for discrete-time
%               systems)
%
%
% See also  LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function splot(sys,T,choice,xrange)

if nargin < 2,
  error('usage: splot(sys,choice{,xrange})');
end

[rs,cs]=size(sys);
if ~islsys(sys),
   error('SYS must be a SYSTEM matrix');
end

[a,b,c,d,e]=ltiss(sys);
if norm(e-eye(size(e)),1) > 0,
  a=e\a; b=e\b;
end
if isempty(d), error('SYS has no input nor output'); end



if isstr(T),    % continous-time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3, xrstr=[]; else xrange=choice; xrstr=',xrange'; end
choice=T(1:2);
stsp=1;

% conversion to N,D in SISO case
if ~isempty(findstr(choice,'bonyni')) & all(size(d)==[1 1]),
   [num,den]=ss2tf(a,b,c,d);
   if max(abs(num)) < 1e14 & max(abs(den)) < 1e14, stsp=0; end
end


if strcmp(choice,'bo'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  Bode plot drawn from input 1 to outputs');
   end
   if stsp,
      eval(['bode(a,b,c,d,1' xrstr ');']);
   else
      eval(['bode(num,den' xrstr ');']);
   end

elseif strcmp(choice,'ny'),

   if any(size(d)~=[1 1]),
     error('Nyquist plot only for SISO systems');
   elseif stsp,
     eval(['nyquist(a,b,c,d,1' xrstr ');']);
   else
     eval(['nyquist(num,den' xrstr ');']);
   end

elseif strcmp(choice,'ni'),

   if any(size(d)~=[1 1]),
     error('Nichols plot only for SISO systems');
   elseif stsp,
     ngrid('new'), eval(['nichols(a,b,c,d,1' xrstr ');']);
   else
     ngrid('new'), eval(['nichols(num,den' xrstr ');']);
   end

elseif strcmp(choice,'li'),

   eval(['linlog(a,b,c,d' xrstr ');']);

elseif strcmp(choice,'sv'),

   eval(['sigma(a,b,c,d' xrstr ');']);

elseif strcmp(choice,'st'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  step response drawn from input 1 to outputs');
   end
   eval(['step(a,b,c,d,1' xrstr ');']);

elseif strcmp(choice,'im'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  impulse response drawn from input 1 to outputs');
   end
   eval(['impulse(a,b,c,d,1' xrstr ');']);

elseif strcmp(choice,'si'),
   if nargin < 3,
     error('Specify the period of the sine wave in XRANGE')
   elseif size(d,2) > 1,
     disp('WARNING in SPLOT:  response drawn from input 1 to outputs');
     d=d(:,1); b=b(:,1);
   end

   w=2*pi/xrange;
   linsim('sinsml',5*xrange,[],[],[],a,b,c,d,w); hold
   set(gca,'title',text(0,0,'Response to a sine wave (in yellow)'));
   t=[0:0.02*xrange:5*xrange];
   plot(t,sin(w*t),'b'); hold off

elseif strcmp(choice,'sq'),
   if nargin < 3,
     error('Specify the period of the square wave in XRANGE')
   elseif size(d,2) > 1,
     disp('WARNING in SPLOT:  response drawn from input 1 to outputs');
     d=d(:,1); b=b(:,1);
   end

   linsim('sqsml',3*xrange,[],[],[],a,b,c,d,xrange); hold
   set(gca,'title',text(0,0,'Response to a square wave (in yellow)'));
   t=[0:.01*xrange:3*xrange];
   u=(rem(t,xrange)<=xrange/2);
   plot(t,u,'b'); hold off


end




else    % discrete-time
%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4, xrstr=[]; else xrstr=',xrange'; end
choice=choice(1:2);

if strcmp(choice,'bo'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  Bode plot drawn from input 1 to outputs');
   end
   if size(d,1)==1,
      [num,den]=ss2tf(a,b,c,d);
      eval(['dbode(num,den,T' xrstr ');']);
   else
      eval(['dbode(a,b,c,d,T,1' xrstr ');']);
   end

elseif strcmp(choice,'ny'),

   if any(size(d)~=[1 1]),
     error('Nyquist plot only for SISO systems');
   else
     [num,den]=ss2tf(a,b,c,d);
     eval(['dnyquist(num,den,T' xrstr ');']);
   end

elseif strcmp(choice,'ni'),

   if any(size(d)~=[1 1]),
     error('Nichols plot only for SISO systems');
   else
     [num,den]=ss2tf(a,b,c,d);
     ngrid('new'), eval(['dnichols(num,den,T' xrstr ');']);
   end


elseif strcmp(choice,'sv'),

   eval(['dsigma(a,b,c,d,T' xrstr ');']);

elseif strcmp(choice,'st'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  step response drawn from input 1 to outputs');
   end
   eval(['dstep(a,b,c,d,1' xrstr ');']);

elseif strcmp(choice,'im'),

   if size(d,2) > 1,
     disp('WARNING in SPLOT:  impulse response drawn from input 1 to outputs');
   end
   eval(['dimpulse(a,b,c,d,1' xrstr ');']);

elseif strcmp(choice,'si'),
   if nargin < 4,
     error('Specify the period of the sine wave in XRANGE')
   elseif size(d,2) > 1,
     disp('WARNING in SPLOT:  response drawn from input 1 to outputs');
     d=d(:,1); b=b(:,1);
   end

   t=[0:T:5*xrange]';
   u=sin(2*pi/xrange*t);
   dlsim(a,b,c,d,u);
   set(gca,'title',text(0,0,'Response to a sine wave'));

elseif strcmp(choice,'sq'),
   if nargin < 4,
     error('Specify the period of the square wave in XRANGE')
   elseif size(d,2) > 1,
     disp('WARNING in SPLOT:  response drawn from input 1 to outputs');
     d=d(:,1); b=b(:,1);
   end

   t=[0:T:3*xrange]';
   u=(rem(t,xrange)<=xrange/2);
   dlsim(a,b,c,d,u);
   set(gca,'title',text(0,0,'Response to a square wave'));


end


end
