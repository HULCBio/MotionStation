function [sys,opcond,J] = getOpenLoopModel(opcond,Blocks);
%Obtains a linear model open loop from a Simulink model given a set of operating conditions.
%
%  Usage:
%   [SYS,opcond] = getOpenLoopModel(OPCOND,block);

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

%% Get the states and input levels
[x,u] = getXU(opcond);
hin = [];
hout = [];

for ct = 1:length(Blocks)
    %% Get the UDD block handle
    bh = get_param(Blocks{ct},'Object');

    %% Get ready to create the I/O required for linearization
    hin = [hin;LinearizationObjects.LinearizationIO];
    %% Set the Block and PortNumber properties
    hin(ct).Type = 'in';
    %% Store the block name
    if isa(Blocks{ct},'string')
        hin(ct).Block = Blocks{ct};
    else
        hin(ct).Block = getfullname(Blocks{ct});
    end
    hin(ct).PortNumber = 1;

    %% Create the output linearization point
    hout = [hout;LinearizationObjects.LinearizationIO];
    %% Get the source block
    hout(ct).Type = 'out';
    SourceBlock = get_param(bh.PortConnectivity(1).SrcBlock,'Object');
    SourceParent = get_param(bh.PortConnectivity(1).SrcBlock,'Parent');
    hout(ct).Block = [SourceParent,'/',SourceBlock.Name];
    %% Get the source port
    hout(ct).PortNumber = bh.PortConnectivity(1).SrcPort + 1;
    %% Set the open loop flag
    hout(ct).OpenLoop = 'on';
end

%% Get the closed loop io conditions that are specified in the model
oldio = getio(opcond.Model);

%% Create an io condition for the closed loop signals along with
%% the control signals where the loop is opened at the output of
%% the controller
%%                       ----------   
%%    Closed Loop Input  |        |  Closed Loop Output
%%                w ---->|   P    |----> z
%%    Control Signal     |        |  Feedback Signal
%%                  |--->|        |----|
%%                  |    ----------    |
%%                  |                  |
%%                  |    ----------    |
%%                  | u  |        |  y |
%%                  -- --|   K    |<- -|
%%                       |        |
%%                       ----------
%%
%%          dx = Ax + B [w; u]
%%     [y; z]  = Cx + D [w; u]
[sys,opcond,J] = linearize(opcond,[oldio;hin;hout]);

%% Reset the old Analysis I/O settings
setio(opcond.Model,oldio);