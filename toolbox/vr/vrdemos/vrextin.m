function [sys, x0, str, ts] = vrextin(t,x,u,flag,Ts,vr_world,vr_field)
%VREXTIN S-function for signal input from virtual reality in RTW
%   external mode. This M-file is used as a Simulink S-function block.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/06/17 11:41:04 $ $Author: Xjhouska $

switch flag

% Initialization
  case 0

    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = 1;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;

    sys = simsizes(sizes);
    str = [];

    if ~isempty(Ts)
      ts = [Ts(1) 0];
    else
      ts = [-1 0];
    end

    x0=[];

    wh=vrworld(vr_world);
    if (~isopen(wh))                                 % open the world if it is not yet open
      open(wh);
    end
    idx=find([vr_field '.']=='.');
    node_name=vr_field(1:idx(1)-1);                  % extract node name
    field_name=vr_field(idx(1)+1:idx(2)-1);          % extract field name
    nh=vrnode(wh,node_name);
    sync(nh,field_name,'on');
    field_value = getfield(nh,field_name);
    set_param([gcs '/value'],'Value', ['[' num2str(field_value) ']']);


% Update
  case 2

    wh=vrworld(vr_world);
    idx=find([vr_field '.']=='.');
    node_name=vr_field(1:idx(1)-1);                  % extract node name
    field_name=vr_field(idx(1)+1:idx(2)-1);          % extract field name
    nh=vrnode(wh,node_name);
    field_value = getfield(nh,field_name);
    set_param([gcs '/value'],'Value', ['[' num2str(field_value) ']']);

    sys=[];

% Unused flags
  case { 1, 3, 4, 5, 9 }
    sys = [];

% Other flags
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

% end vrextin
