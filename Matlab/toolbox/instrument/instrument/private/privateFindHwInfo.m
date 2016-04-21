function [serialPorts, gpibInfo, visaAdaptors, visaConstructors] = privateFindHwInfo(varargin)
%PRIVATEFINDHWINFO Find available instruments.
%
%   PRIVATEFINDHWINFO finds the available serial port, GPIB and VISA instruments.
%
%   This function should not be called directly by the user.
%  

%   MP 11-10-02
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/03/30 13:06:28 $

info = instrhwinfo('serial');
serialPorts = info.SerialPorts;

% GPIB and VISA are not supported on Linux.
if strcmp(computer, 'GLNX86')
    gpibInfo = {};
    visaAdaptors = {};
    visaConstructors = {};
    return;
end

gpibInfo = localParseGPIB;

info = instrhwinfo('visa');
visaAdaptors = info.InstalledAdaptors;

% Can only have one VISA dll installed.
if length(visaAdaptors) == 1
    % Get the Constructors.
    temp = instrhwinfo('visa', visaAdaptors{1});
    tempConstructors = temp.ObjectConstructorName;
    visaConstructors = cell(size(tempConstructors));
    
    % Extract out the resource names.
    index = findstr(tempConstructors{1}, ',');
    for i=1:length(visaConstructors)
        vconst = tempConstructors{i};
        visaConstructors{i} = vconst(index+3:length(vconst)-3);
    end
else
    visaAdaptors = {};
    visaConstructors = {};
end

% --------------------------------------------------------------------------
% Find the available GPIB hardware, board indices and primary addresses.
% out will be of the form: adaptor, cell array of board indices, cell array of
% cells that contain the primary addresses for each board index listed.
function out = localParseGPIB

% Initialize output.
out = {};

gpibInfo = instrhwinfo('gpib');
gpibAdaptors = gpibInfo.InstalledAdaptors;

for i = 1:length(gpibAdaptors)
    info = instrhwinfo('gpib', gpibAdaptors{i});
    
    % Extract the BoardIndex and Primary Address information.
    bids         = info.InstalledBoardIds;
    constructors = info.ObjectConstructorName;
    
    % Convert board indices to cell if necessary.
    bids = localFormatBoardIndices(bids);
    
    % Loop through each board index and find the associated primary
    % addresses.   
    pads = {};
    command = ['gpib(''' gpibAdaptors{i} ''', '];
    
    for j=1:length(bids)
        pad = {};
        commandWithBid = [command num2str(bids{j}) ', '];
        for k=1:length(constructors)
            constructor = constructors{k};
            if ~isempty(findstr(commandWithBid, constructor))
                constructor = strrep(constructor, commandWithBid, '');
                constructor = strrep(constructor, ');', '');
                pad = {pad{:}, constructor};  
            end
        end
        pads = {pads{:} pad};
    end
    
    % Out consists of adaptor, unique board indices and a cell array of 
    % primary addresses for each board index.
    out = {out{:} gpibAdaptors{i} bids, pads}; 
end

% --------------------------------------------------------------------------
% Format the Board Indices into a cell array of string.
function bids = localFormatBoardIndices(bid)

bids = cell(1, length(bid));
for i = 1:length(bid)
    bids{i} = num2str(bid(i));
end


