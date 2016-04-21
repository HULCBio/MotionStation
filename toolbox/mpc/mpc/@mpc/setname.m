function setname(MPCobj,type,index,name)
%SETNAME Set I/O signal names in MPC prediction model
%
%   SETNAME(MPCobj,'input',I,NAME) change the name of I-th input signal
%   to NAME.
%
%   SETNAME(MPCobj,'output',I,NAME) change the name of I-th output signal
%   to NAME.
%
%   See also GETNAME, MPC, SET.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:14 $

if nargin<1,
    error('mpc:setname:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:setname:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:setname:empty','Empty MPC object');
end

if nargin<2,
    error('mpc:setname:emptytype',...
        'You must supply a signal type, valid types are ''input and ''output''');
end
errmsg='Invalid signal type, valid types are ''input and ''output''';
if ~ischar(type),
    error('mpc:setname:wrongtype',errmsg);
end
type=lower(type);
isinput=~isempty(strfind('input',type));
isoutput=~isempty(strfind('output',type));
if ~isinput & ~isoutput,
    error('mpc:setname:wrongtype',errmsg);
end
if isinput & isoutput,
    error('mpc:setname:ambtype','Ambiguous signal type');
end

if nargin<3,
    error('mpc:setname:emptyindex','You must supply a signal index');
end
if isinput,
    nutot=MPCobj.MPCData.nutot;
    nn=nutot;
else
    ny=MPCobj.MPCData.ny;
    nn=ny;
end
errmsg=sprintf('Invalid %s index, should be between 1 and %d',type,nn);
if ~isnumeric(index),
    error('mpc:setname:wrongindex',errmsg);
end
if prod(size(index))~=1 | index>nn | index<1 | ~index==round(index),
    error('mpc:setname:wrongindex',errmsg);
end

if nargin<4 | isempty(name),
    name='';
end
if ~ischar(name)
    error('mpc:setname:name','Invalid signal name');
end

if isinput,
    MPCobj.Model.Plant.InputName{index}=name;
end
if isoutput,
    MPCobj.Model.Plant.OutputName{index}=name;
end

mvindex=MPCobj.MPCData.mvindex;
mdindex=MPCobj.MPCData.mdindex;
unindex=MPCobj.MPCData.unindex;
myindex=MPCobj.MPCData.myindex;
uyindex=setdiff([1:MPCobj.MPCData.ny]',myindex(:));

% Update MD/UD/OV properties
if isinput,
    for i=1:length(mvindex),
        j=mvindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.ManipulatedVariables(i).Name=name;
    end
    nv=length(mdindex);
    for i=1:nv,
        j=mdindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.DisturbanceVariables(i).Name=name;
    end
    for i=1:length(unindex),
        j=unindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.DisturbanceVariables(nv+i).Name=name;
    end
end
if isoutput,
    for i=1:length(myindex),
        j=myindex(i);
        name=MPCobj.Model.Plant.OutputName{j};
        MPCobj.OutputVariables(j).Name=name;
    end
    for i=1:length(uyindex),
        j=uyindex(i);
        name=MPCobj.Model.Plant.OutputName{j};
        MPCobj.OutputVariables(j).Name=name;
    end
end

try
    assignin('caller',inputname(1),MPCobj);
end