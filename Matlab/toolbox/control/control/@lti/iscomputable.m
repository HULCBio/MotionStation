function [boo,errmsg] = iscomputable(sys,ResponseType,NormalRefresh,varargin)
%ISCOMPUTABLE  True if requested system response is computable.
%
%   TF = ISCOMPUTABLE(SYS,PLOTTYPE,NORMALREFRESH,...)

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/01/07 19:32:04 $

errmsg = '';
switch ResponseType
   
case {'step','impulse'}
   % Time responses
   if ~isproper(sys)
      errmsg = 'Not supported for non-proper models.';
   elseif isa(sys,'frd')
      errmsg = 'Not supported for Frequency Response Data models.';
   elseif ~isreal(sys)
      errmsg = 'Not supported for models with complex data.';
   elseif NormalRefresh && ~hasConsistentSampleTime(varargin{1},sys)
      errmsg = 'Time sample spacing must match sample time of discrete-time models.';
   end

case 'initial'
   % Initial response
   if ~isa(sys,'ss')
      errmsg = 'Only available for state-space models.';
   elseif any(sys.ioDelay(:)),
      errmsg = 'Not applicable to models with I/O delays.';
   elseif ~isreal(sys)
      errmsg = 'Not supported for models with complex data.';
   elseif NormalRefresh 
      if ~hasConsistentSampleTime(varargin{1},sys)
         errmsg = 'Time sample spacing must match sample time of discrete-time models.';
      else
         order = size(sys,'order');  % system order
         x0 = varargin{2};           % initial state
         lx0 = length(x0);
         if ~isnumeric(x0) | lx0~=prod(size(x0))
            errmsg = 'Initial condition X0 must be a numeric vector.';
         elseif any(~isfinite(x0))
            errmsg = 'Initial condition X0 contains Inf or NaN.';
         elseif any(order~=lx0)
            if all(lx0~=order)
               errmsg = sprintf('Length of initial condition X0 must match number of states.');
            else
               errmsg = sprintf('All models must have the same number of states.');
            end
         end
      end
   end
   
case 'lsim'
   % Linear simulation
   [t,x0,u] = deal(varargin{1:3});
   su = size(u);
   if ~isproper(sys)
      errmsg = 'Not supported for non-proper models.';
   elseif isa(sys,'frd')
      errmsg = 'Not supported for Frequency Response Data models.';
   elseif ~isreal(sys)
      errmsg = 'Not supported for models with complex data.';
   elseif NormalRefresh
      if ~isnumeric(u) | ndims(u)>2,
         errmsg = 'Input data U must be a 2D numeric array.';
      elseif any(~isfinite(u(:)))
         errmsg = 'Input data U contains Inf or NaN.';
      elseif su(2)~=size(sys,2)
         errmsg = 'Input data U must have as many columns as system inputs.';
      elseif length(t)~=su(1)
         errmsg = 'Input data U and time vector T must have the same number of samples.';
      elseif length(t)<2
         errmsg = 'Input data U must contain at least two samples.';
      elseif ~hasConsistentSampleTime(t,sys)
         errmsg = 'Time sample spacing must match sample time of discrete-time models.';
      elseif isa(sys,'ss') & ~isempty(x0)       
         % Validate IC
         lx0 = length(x0);
         order = size(sys,'order');
         if any(sys.ioDelay(:)),
            errmsg = 'Initial condition X0 is ambiguous for state-space models with I/O delays.';
         elseif ~isnumeric(x0) | lx0~=prod(size(x0))
            errmsg = 'Initial condition X0 must be a numeric vector.';
         elseif any(~isfinite(x0))
            errmsg = 'Initial condition X0 contains Inf or NaN.';
         elseif any(lx0~=order)
            if all(lx0~=order)
               errmsg = sprintf('Length of initial condition X0 must match number of states.');
            else
               errmsg = sprintf('All models must have the same number of states.');
            end
         end
      end
   end   
   
case 'pzmap'
   % Pole/zero map
   if isa(sys,'frd')
      errmsg = 'Not supported for Frequency Response Data models.';
   elseif ~issiso(sys) && ~isproper(sys)
      errmsg = 'Not supported for improper MIMO models.';
   end
   
case 'iopzmap'
   % Pole/zero map for individual I/O pairs
   if isa(sys,'frd')
      errmsg = 'Not supported for Frequency Response Data models.';
   end
   
case 'rlocus'
   % Root locus
   if isa(sys,'frd')
      errmsg = 'Not supported for Frequency Response Data models.';
   elseif ~issiso(sys) 
      errmsg = 'RLOCUS is only applicable to SISO models.';
   elseif hasdelay(sys)
      errmsg = 'RLOCUS is not applicable to continuous-time models with delays.';
   elseif ~isreal(sys)
      errmsg = 'Not supported for models with complex data.';
   end
      
end

boo = (isempty(errmsg));

%----------------------- Local Function ---------------------------

function boo = hasConsistentSampleTime(t,sys)
% Checks if supplied time vector is compatible with system sample time
boo = true;
if length(t)>2
   Ts = get(sys,'Ts');
   if Ts>0 & abs(t(2)-t(1)-Ts)>1e-4*Ts
      boo = false;
   end
end