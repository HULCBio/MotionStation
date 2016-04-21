function privateUpdateSampleRate(obj, sampleRate, scope)
%PRIVATEUUPDATESAMPLERATE Update the softscope samplerate.
%
%   PRIVATEUUPDATESAMPLERATE(OBJ, SAMPLERATE, SCOPE) updates softscope analoginput
%   object's, OBJ, SampleRate property to SAMPLERATE. The following updates are 
%   also made to softscope:
%
%       1. All the data is removed from each channel
%       2. Each display's start time is reset to zero.
%    
%   PRIVATEUUPDATESAMPLERATE is a helper function for the softscope function.
%   It is called when the Edit -> SampleRate menu item is selected from softscope.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:35 $

import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.mwt.MWFrame;

oldSampleRate = get(obj, 'SampleRate');
try
    actualSampleRate = setverify(obj, 'SampleRate', sampleRate);
    if (actualSampleRate ~= sampleRate)
        MWAlert.warningAlert(MWFrame, 'Sample Rate', 'The sample rate has been rounded to the closest supported sample rate.', MWAlert.BUTTONS_OK);
    end
catch
    % Extract only the message from the error.
    msg = lasterr;
    index = findstr(sprintf('\n'), msg);
    if ~isempty(index)
        msg = msg(index(end)+1:length(msg));
    end
    
    % Show error in dialog box.
    MWAlert.errorAlert(MWFrame, 'Invalid Sample Rate', msg, MWAlert.BUTTONS_OK); 
end

if (oldSampleRate ~= actualSampleRate)
    scope.updateSampleRate(actualSampleRate);
end


