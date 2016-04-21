function this = SliderObject(Value,Min,Max,isLog)

% Constructor for Slider java/UDD object

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:21 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;

this = mpcobjects.SliderObject;
this.Panel = com.mathworks.toolbox.mpc.MPCSlider(this);
set(this,'Minimum',Min,'Maximum',Max,'isLog',isLog);
this.Slider = this.Panel.Slider;
this.TextField = this.Panel.TextField;
this.isEnabled = 1;
this.Listener = handle.listener(this, this.findprop('Value'), ...
    'PropertyPostSet', {@LocalValueListener, this});
this.enableListener = true;
this.Value = Value;

    
function LocalValueListener(eventSrc, eventData, this)

if this.enableListener
    intValue = this.getIntegerValue;
    textValue = this.getStringValue;
    this.Panel.UDDupdateSlider(intValue, textValue);
end