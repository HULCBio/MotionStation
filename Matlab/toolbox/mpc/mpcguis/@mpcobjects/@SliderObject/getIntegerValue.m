function intVal = getIntegerValue(this)

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:22 $

javaSlider = this.Panel.Slider;
intMin = javaSlider.getMinimum;
intMax = javaSlider.getMaximum;

if this.isLog
    % Log scaling
    intVal = intMin + round((intMax - intMin)*(log(this.Value/this.Minimum)/ ...
        log(this.Maximum/this.Minimum)));
else
    intVal = intMin + round((intMax - intMin)*(this.Value - this.Minimum)/ ...
        (this.Maximum - this.Minimum));
end
