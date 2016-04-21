% COMMBLKREADWKSPC Helper function for the sampled read from workspace blocks

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:44:41 $

% --- Set the offset time
ts=td(1);
if (length(td)>=2)
   off=td(2);
else 
   off=0;
end;

% --- Ensure that the initial output is correct at time=0
ic = X(1,:);

% --- Ensure that the block operates with vectors as required
[n,m]=size(X);
if(n==1)
   SamplesPerFrame = m;
else
   SamplesPerFrame = 1;
end;

if (cyc == 1)
   X = [X(2:end,:); X(1,:)];
else
   X = X(2:end,:);
end;


% --- Set the cyclic flag
if (cyc == 0 & strcmp(get_param([gcb '/Triggered Signal From Workspace'],'cyclic'),'on'))
  	set_param([gcb '/Triggered Signal From Workspace'], 'cyclic', 'off');
elseif (cyc == 1 & strcmp(get_param([gcb '/Triggered Signal From Workspace'],'cyclic'),'off'))
   set_param([gcb '/Triggered Signal From Workspace'], 'cyclic', 'on');
end;
