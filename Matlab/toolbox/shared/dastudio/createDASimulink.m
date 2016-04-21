function das = createDASimulink(descriptor)

    if nargin==0
        das = make_l('Global');
    elseif isempty(descriptor)
        das = [];
    elseif ischar(descriptor)
        das = make_l(descriptor);
    else
        for index = 1:length(descriptor)
            if iscell(descriptor)
                desc = descriptor{index};
            else
                desc = descriptor(index);
            end
            das(index) = make_l(desc);
        end
    end


function das = make_l(desc)
    desc = force_to_handle_l(desc);
    das = archive_l(desc);
    if isempty(das)
        try
            das = dastudio.Simulink(desc);
        catch
            das = dastudio.Simulink;
            das.construct(desc);
        end
        if isempty(das.Mask)
            das.delete;
            das = [];
        else
            archive_l(desc, das);
        end
    end


function desc = force_to_handle_l(desc)
    if ischar(desc)
        if ~strcmpi(desc, 'Global')
            % simulink path
            try
                desc = get_param(desc, 'handle');
            catch
                % error
                desc = [];
            end
        end
    end


function out = archive_l(desc, hand)
    persistent handles;
    persistent descriptors;

    persistent simulinkGlobal;

    out = [];

    if nargin == 1
        if strcmpi(desc, 'Global')
            out = simulinkGlobal;
        elseif ~isempty(descriptors)
            out = handles(descriptors==desc);
        end
    else
        if strcmpi(desc, 'Global')
            simulinkGlobal = hand;
        elseif ishandle(desc)
            if isempty(descriptors)
                handles = hand;
                descriptors = desc;
            else
                len = length(handles)+1;
                handles(len) = hand;
                descriptors(len) = desc;
            end
        end
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:59 $
