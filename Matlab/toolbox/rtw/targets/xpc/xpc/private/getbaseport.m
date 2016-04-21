function par=getbaseport(arg1,arg2)

% GETBASEPORT - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:19:20 $


if nargin == 0
	par=name2Port('rl32UdpBase');
  	if strcmp(par,'no_data')
   	par=22300;
  	else
     	par=str2num(par);
  	end
  	return
end

if nargin == 1
	if strcmp(arg1,'Text')
      par=name2Port('rl32UdpBaseText');
      if strcmp(par,'no_data')
         par=getbaseport;
      else
         par=str2num(par);
      end
      return
   end
   if strcmp(arg1,'Binary')
      par=name2Port('rl32UdpBaseBinary');
      if strcmp(par,'no_data')
         par=getbaseport+10;
      else
         par=str2num(par);
      end
      return
   end;
   error('first argument can either be Text or Binary');
end

if nargin == 2
   if strcmp(arg1,'Text')
      t1='t';
   elseif strcmp(arg1,'Binary')
      t1='b';
   else
      error('first argument can either be Text or Binary');
   end;
   if not(arg2 > 0 & arg2 < 10)
      error('second argument has to be in the range 1 .. 9');
   else
      par=name2Port(['xpctarget',t1,'chan',char(double('0')+ arg2)]);
   end;
   if strcmp(par,'no_data')
      par=getbaseport(arg1) + arg2 - 1;
   else
      par=str2num(par);
   end;
end;
 
