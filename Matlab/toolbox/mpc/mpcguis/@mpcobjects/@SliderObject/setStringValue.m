function setStringValue(this, javaStringIn)

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:27 $

this.enableListener = false;
numVal = str2num(javaStringIn);
if isempty(numVal)
    % User entry wasn't a valid number.  Ignore it -- return
    % current value instead.
    textValue = this.getStringValue;
elseif numVal(1) < this.Minimum
    % Saturate at minimum
    this.Value = this.Minimum;
    textValue = num2str(this.Minimum);
elseif numVal(1) > this.Maximum
    % Saturate at maximum
    this.Value = this.Maximum;
    textValue = num2str(this.Maximum);
else
    this.Value = numVal(1);
    textValue = num2str(this.Value);
end

intValue = this.getIntegerValue;
this.Panel.UDDupdateSlider(intValue, textValue);
this.enableListener = true;