function setStorageOptionDependentParamValues(handles,arg);
% Sets uicontrol values according to data in specified "arg" structure
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:17 $

if arg.isPtr && ~strcmp(arg.name,'Return value'),
    switch arg.storageOption,
        case 'Specify address',
            a = arg.address;
            if isempty(a),
                a = 0;
            end
            str1 = ['0x' dec2hex(a(1))];
            if length(a) < 2,
                a(2) = 0;
            end
            str2 = [str1 ', ' num2str(a(2))];
            set(handles.addressEditBoxTag,'string',str2);
        case 'Global variable',
            set(handles.globVarNameEditBoxTag,'string',arg.globVarName);
        case 'Automatic',
            % NOP    
    end
end
