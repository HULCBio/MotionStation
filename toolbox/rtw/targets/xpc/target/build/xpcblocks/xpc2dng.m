function [sys,x0,str,ts] = xpc2dng(t,x,u,flag,sampletime, signal)
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $

switch flag
  
  case 0   
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 1;
    sizes.NumInputs      = 0;  
    sizes.DirFeedthrough = 0;
    sizes.NumSampleTimes = 1;
    sys = simsizes(sizes);
    str = [];
    x0  = [];
    ts  = [sampletime 0];   
    
    blk=get_param(gcb,'parent');    
    if  strcmp(get_param(blk,'appname'),'''''')
        error(['The xPC Target application name parameter',...
              ' must be specifed in the dialog parameters'])
    end    
    
  case 3
    sys=xpcgate('getmonsignals',signal);
    
  case { 1, 2, 4, 9}
    sys=[];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end


