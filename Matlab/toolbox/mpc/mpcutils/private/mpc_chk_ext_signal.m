function z=mpc_chk_ext_signal(signal,name,nn,ts,offset,t0);

% MPC_CHK_EXT_SIGNAL Take signal_name from MPC Simulink mask, extract a signal structure 
% (in the 'To Workspace' format), and returns a discrete-time signal

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:52 $   

errmsg=[name ' signal is not valid'];

if isempty(signal),
   signal=struct('time',0,'signals',struct('values',zeros(1,nn)));
end

if isa(signal,'double') & prod(size(signal))==1,
   if isfinite(signal),
      signal=struct('time',0,'signals',struct('values',signal*ones(1,nn)));
   else
      error('mpc:mpc_chk_ext_signal:real',[errmsg ', must be real valued']);
   end
end

if ~isa(signal,'struct'),
   error('mpc:mpc_chk_ext_signal:struct',errmsg);
end

% Now left with a structure
toworkerr='(See ''To Workspace'' block)';

if ~isfield(signal,'time'),
   error('mpc:mpc_chk_ext_signal:time',[errmsg ', must have a field ''time''' toworkerr]);
end
time=signal.time;
if ~isa(time,'double'),
   error('mpc:mpc_chk_ext_signal:timereal',[errmsg ', ''time'' must be real valued']);
end

if ~isfield(signal,'signals'),
   error('mpc:mpc_chk_ext_signal:signals',[errmsg ', must have a field ''signals''' toworkerr]);
end
if ~isfield(signal.signals,'values'),
   error('mpc:mpc_chk_ext_signal:values',[errmsg ', must have a field ''signals'' and subfield ''values''' toworkerr]);
end

values=signal.signals.values;
if ~isa(time,'double'),
   error('mpc:mpc_chk_ext_signal:valuereal',[errmsg ', ''signals.values'' must be real valued']);
end

if isfield(signal.signals,'dimensions'),
   dims=signal.signals.dimensions;
   if dims~=nn,
      error('mpc:mpc_chk_ext_signal:dim',[errmsg ', invalid dimensions']);
   end
end

if size(values,2)~=nn,
   error('mpc:mpc_chk_ext_signal:dim',[errmsg ', invalid dimensions']);
end

clear signal

% Resample

zorig=values';
clear values

z=[];
lastt=t0; 
i=1;
t2=time(1);
t1=t2;
z2=zorig(:,1)-offset;

% Fill t up to time(1) (included)
while lastt<=time(1),
   z=[z,z2];
   lastt=lastt+ts;
end

lent=length(time);

while i<=lent-1 & lastt<time(lent),
   while t2<lastt,
      t1=t2;
      z1=z2;
      t2=time(i+1);
      i=i+1; % takes next sample
   end   
   z2=zorig(:,i)-offset;
   z1=zorig(:,i-1-offset);
   while lastt<=t2,
      znew=z2+(z1-z2)/(t1-t2)*(lastt-t2); % Linear interpolation
      z=[z,znew];
      lastt=lastt+ts;
   end
end  

if lastt-1<time(lent),
   z1=zorig(:,lent-1)-offset;
   z2=zorig(:,lent)-offset;
   t1=time(lent-1);
   t2=time(lent);
   znew=z2+(z1-z2)/(t1-t2)*(lastt-t2); % Linear interpolation
   z=[z,znew];
end   


%end mpc_chk_ext_signal
