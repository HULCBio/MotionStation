function [sys,sysname,PlotStyle,T,Tdata,Tsdemand] = sysirdec(na,varargin)
%SYSIRDEC   Decodes the input list for IMPULSE AND STEP

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/10 23:20:31 $

ni = length(varargin);
no = nargout;
newarg=[];inpn=[];
T = []; Tdata = []; Tsdemand = [];
%First find desired time span, if specified. That is a double, not
%preceeded by 'pw' nor 'sd':
for j = 1:ni
    if isa(varargin{j},'double')
        if j==1
            error('The first argument to IMPULSE/STEP cannot be a number.')
        end
         tst = varargin{j-1};
        if ischar(tst)&(strcmp(lower(tst),'pw')|strcmp(lower(tst),'sd'))
        else
             T = varargin{j};
        end
    end
end
% Parse input list
for j=1:ni
   if isa(varargin{j},'lti')
      newarg = [newarg,{idss(varargin{j})}];
      inpn = [inpn,{inputname(j+1)}];
      
   elseif isa(varargin{j},'frd')|isa(varargin{j},'idfrd')
       varargin{j}=iddata(idfrd(varargin{j}));
      %error('Frequency responses cannot be used in IMPULSE  and STEP.')
       model = impulse(varargin{j},'pw',na,T);
      ut = pvget(model,'Utility');
      Tdata = ut.impulse.time;
      newarg = [newarg,{model}];
      inpn = [inpn,{inputname(j+1)}]; 
  elseif isa(varargin{j},'iddata');
      model = impulse(varargin{j},'pw',na,T);
      ut = pvget(model,'Utility');
      Tdata = ut.impulse.time;
      newarg = [newarg,{model}];
      inpn = [inpn,{inputname(j+1)}]; 
   else      
      newarg=[newarg,varargin(j)];
      inpn = [inpn,{inputname(j+1)}];
   end
end
varargin = newarg;ni = length(varargin);
inputname1 = inpn;
nsys = 0;       % counts LTI systems
nstr = 0;      % counts plot style strings 
nw = 0;
sys = cell(1,ni);
sysname = cell(1,ni);
PlotStyle = cell(1,ni);
m=inf;
lastsyst=0;lastplot=0;

for j=1:ni,
   argj = varargin{j};
   if isa(argj,'idmodel') 
      if ~isempty(argj)
         if isaimp(argj)
            ut = pvget(argj,'Utility');
            Tdata = ut.impulse.time;
         end
         if isnan(argj)
             warning('Model containing NaNs is ignored.')
             lastsyst = j;
         else
         nsys = nsys+1;   
         sys{nsys} = argj;
         sysname{nsys} = inputname1{j};lastsyst=j;
     end
      end
   elseif isa(argj,'char')&j>1&(isa(varargin{j-1},'idmodel'))
      %if ~any(strcmp(lower(argj(1)),{'s','a','p'})) % to cut off a/p and 'same'
      nstr = nstr+1;   
      PlotStyle{nsys} = argj; lastplot=j;
      %end
   end
end
if lastplot==lastsyst+1,lastsyst=lastsyst+1;end
kk=1;
newarg=[];
if ni>lastsyst
   for j=lastsyst+1:ni
      newarg{kk}= varargin{j};kk=kk+1;
   end
else
   newarg={};
end
sys = sys(1:nsys);
sysname = sysname(1:nsys);
PlotStyle = PlotStyle(1:nsys);
% Now dissect newarg
if length(newarg)>1
   error(['The argument list could not be parsed. Please check the call.'])
elseif length(newarg)==1
   T = newarg{1};
   if length(T)>2
       Tsdemand = T(2)-T(1);
       if ~all(abs(diff(T)-Tsdemand)<Tsdemand/1000)
           error('The demanded time span must be equidistant.')
       end
   end
else 
   T = [];
end
