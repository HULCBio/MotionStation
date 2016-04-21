function name=getname(MPCobj,type,index)
%GETNAME Get I/O signal names in MPC prediction model
%
%   NAME=GETNAME(MPCobj,'input',I) get the name of I-th input signal
%   NAME=GETNAME(MPCobj,'output',I) get the name of I-th output signal
%
%   See also SETNAME, MPC, SET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/01/03 12:23:52 $

if nargin<1,
    error('mpc:getname:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:getname:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:getname:empty','Empty MPC object');
end

if nargin<2,
    error('mpc:getname:emptytype',...
        'You must supply a signal type, valid types are ''input and ''output''');
end
errmsg='Invalid signal type, valid types are ''input and ''output''';
if ~ischar(type),
    error('mpc:getname:wrongtype',errmsg);
end
type=lower(type);
isinput=~isempty(strfind('input',type));
isoutput=~isempty(strfind('output',type));
if ~isinput & ~isoutput,
    error('mpc:getname:wrongtype',errmsg);
end
if isinput & isoutput,
    error('mpc:getname:ambtype','Ambiguous signal type');
end

if nargin<3,
    error('mpc:getname:emptyindex','You must supply a signal index');
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
    error('mpc:getname:wrongindex',errmsg);
end
if prod(size(index))~=1 | index>nn | index<1 | ~index==round(index),
    error('mpc:getname:wrongindex',errmsg);
end


if isinput,
    name=MPCobj.Model.Plant.InputName{index};
end
if isoutput,
    name=MPCobj.Model.Plant.OutputName{index};
end