function out = privateGetObjectInfoForSaving(obj)
%PRIVATEGETOBJECTINFOFORSAVING Return softscope object information needed for saving.
%
%   OUT = PRIVATEGETOBJECTINFOFORSAVING(OBJ) returns softscope object, OBJ, 
%   information needed for saving to OUT. The analoginput object information
%   saved by softscope includes:
%
%       1. AdaptorName
%       2. ID
%       3. SampleRate
%       4. InputType
%       5. Each channel's InputRange
%        
%   PRIVATEGETOBJECTINFOFORSAVING is a helper function for the softscope function.
%   It is called when the Save or Save As menu item is selected from softscope.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:31 $


% Determine the objects Adaptor, ID, SampleRate and InputType for saving.
out = cell(1,4+2*length(get(obj, 'Channel')));

out{1} = daqhwinfo(obj, 'AdaptorName');
out{2} = daqhwinfo(obj, 'ID');
out{3} = num2str(get(obj, 'SampleRate'));
out{4} = get(obj, 'InputType');

% Append each channel's input range.
count = 1;
for i=5:2:length(out)
    out{i} = num2str(get(obj.Channel(count), 'HwChannel'));
    out{i+1} = num2str(get(obj.Channel(count), 'InputRange'));
    count = count+1;
end
