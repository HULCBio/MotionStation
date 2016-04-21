function wrappers = getData(h)

    if (isempty(h.wrappedWorkspace))
        wrappers = [];
        data = evalin('base', 'who');

        for i = 1:length(data)
            name = data{i};
            value = evalin('base', name);
            if isnumeric(value) | islogical(value)
                wrapper = h.getCachedObject(name);
                setMXArray(h, wrapper, name, value)
                wrappers = [wrappers wrapper];
            elseif isa(value, 'Simulink.Data') & isa(value, 'DAStudio.Object')
                wrapper = h.getCachedObject(name);
                wrapper.Object = value;
                wrappers = [wrappers wrapper];
            end
        end
    else
        data = get(h.wrappedWorkspace, 'data');

        for i=1:length(data),
            wrappers(i) = h.getCachedObject(data(i).Name);
            if isnumeric(data(i).Value) | islogical(data(i).Value)
                setMXArray(h, wrappers(i), data(i).Name, data(i).Value);
            else
                wrappers(i).Object = data(i).Value;
            end
        end,
    end


function setMXArray(h, wrapper, name, value)
    if isempty(wrapper.Object) | ~wrapper.Object.isa('DAStudio.MXArray')
        wrapper.Object = DAStudio.MXArray(name, h);
    end
    wrapper.Object.Value = value;


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:37 $
