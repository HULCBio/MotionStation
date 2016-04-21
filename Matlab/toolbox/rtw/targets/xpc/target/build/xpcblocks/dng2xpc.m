function [sys,x0,str,ts] = dng2xpc(t,x,u,flag,paramid)
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $

switch flag
  
  case 0
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = -1;  
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;
    sys = simsizes(sizes);
    str = [];
    x0  = [];
    ts  = [-1 0];
    
    blk = get_param(gcb,'parent');
    blk = get_param(blk,'parent');
    if  strcmp(get_param(blk,'appname'),'''''')
        error(['The xPC Target application name parameter ',...
               ' must be specifed in the dialog parameters'])
    end    

case 3
    xpcgate('setpar',paramid,u');
    sys=[];
    
  case { 1, 2, 4, 9}
    sys=[];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end


