function P=setmpcsignals(P,varargin)

%SETMPCSIGNALS Set signal types in MPC plant model
%
%   P=setmpcsignals(P,SignalType1,Channels1,SignalType2,Channels2,...) set I/O
%   channels of the MPC plant model P (LTI object).
%
%   Valid signal types are:
%
%   MV, Manipulated:              manipulated variables (input channels)
%   MD, MeasuredDisturbances:     measured disturbances (input channels)
%   UD, UnmeasuredDisturbances:   unmeasured disturbances (input channels)
%   MO, MeasuredOutputs:          manipulated variables (output channels)
%   UO, UnmeasuredOutputs:        manipulated variables (output channels)
%
%   Unambiguous abbreviations are accepted.
%
%   P=setmpcsignals(P) set channel assignments to default: all inputs are
%   manipulated variables, all outputs are measured outputs.
%
%   Example. We want to define an MPC object based on the LTI discrete-time
%   plant model P with 4 inputs and 3 outputs. The first and second input
%   as measured disturbances, the third input as unmeasured disturbance,
%   the fourth input as manipulated variable (default), the second output
%   as unmeasured, all other outputs as measured:
% 
%   P=setmpcsignals(P,'MD',[1 2],'UD',[3],'UO',[2]);
%   mpc1=mpc(P);
%
%   NOTE: when using SETMPCSIGNALS to modify an existing MPC object, be
%   sure that the fields Weights, MV, OV, DV, Model.Noise, and
%   Model.Disturbance are consistent with the new I/O signal types.
%
%   See also MPC, SET.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:35:33 $

if nargin<1,
    error('mpc:setmpcsignals:none','No plant model supplied.');
end
if ~isa(P,'lti'),
    error('mpc:setmpcsignals:obj','Invalid plant model, must be an LTI object');
end
if isempty(P),
    error('mpc:setmpcsignals:empty','Empty plant model');
end

ni=nargin;

[ny,nu]=size(P);

% Delete existing channel assignments
IG=[];
OG=[];

if ni==1,
    IG.Manipulated=(1:nu);
    OG.Measured=(1:ny);
    set(P,'InputGroup',IG,'OutputGroup',OG);
    return
end

if round((ni-1)/2)~=(ni-1)/2,
    error('mpc:setmpcsignals:even','Signal type/channels pairs must come in even number. Use SETMPCSIGNALS(MPCobj,SignalType1,Channels1,SignalType2,Channels2, ...)');
end

for i=1:2:ni-1,
    % Set each SV pair in turn
    PropStr = varargin{i};
    if ~isstr(PropStr),
        error('mpc:setmpcsignals:string','Signal names must be single-line strings.')
    end

    propstr=lower(PropStr);

    % Handle multiple names

    ismv=~isempty(strfind(propstr,'mv'))|...
        ~isempty(strfind(propstr,'man'))|...
        ~isempty(strfind(propstr,'inp'));
    ismd=~isempty(strfind(propstr,'md'))|~isempty(strfind(propstr,'dis'));
    isud=~isempty(strfind(propstr,'ud'))|...
        (~isempty(strfind(propstr,'dis')) & ~isempty(strfind(propstr,'un')));
    ismo=~isempty(strfind(propstr,'mo'))|...
        (~isempty(strfind(propstr,'ou')) & ~isempty(strfind(propstr,'meas')) &...
        isempty(strfind(propstr,'un')));
    isuo=~isempty(strfind(propstr,'uo'))|~isempty(strfind(propstr,'umo'))|...
        (~isempty(strfind(propstr,'ou')) & ~isempty(strfind(propstr,'unmeas')));

    if ~(ismv|ismd|isud|ismo|isuo),
        error('mpc:setmpcsignals:unknown','Unknown or ambiguous signal type. Please use MV,MD,UD,MO,UO');
    end

    channels = varargin{i+1};
    if ~isnumeric(channels),
        error('mpc:setmpcsignals:value','Signal channels must be integers');
    end
    channels=channels(:)';

    try
        if ismv,
            if ~isempty(channels),
                IG.Manipulated=channels;
            else
                try
                    IG=rmfield(IG,'Manipulated');
                end
            end
        end
        if ismd,
            if ~isempty(channels),
                IG.Measured=channels;
            else
                try
                    IG=rmfield(IG,'Measured');
                end
            end
        end
        if isud,
            if ~isempty(channels),
                IG.Unmeasured=channels;
            else
                try
                    IG=rmfield(IG,'Unmeasured');
                end
            end
        end
        if ismo,
            if ~isempty(channels),
                OG.Measured=channels;
            else
                try
                    OG=rmfield(OG,'Measured');
                end
            end
        end
        if isuo,
            if ~isempty(channels),
                OG.Unmeasured=channels;
            else
                try
                    OG=rmfield(OG,'Unmeasured');
                end
            end
        end
    catch
        rethrow(lasterror);
    end
end
set(P,'InputGroup',IG,'OutputGroup',OG);

% Assign default groups
[mvindex,mdindex,unindex,myindex,uyindex]=mpc_chkindex(P);
IG.Manipulated=mvindex';
OG.Measured=myindex';
set(P,'InputGroup',IG,'OutputGroup',OG);