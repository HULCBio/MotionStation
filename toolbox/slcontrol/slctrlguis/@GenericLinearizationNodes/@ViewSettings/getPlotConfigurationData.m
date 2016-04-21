function data = getPlotConfigurationData(this);
%getPlotConfigurationData  Method to get the current plot configurations
%for a view.
%
%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

NUMBER_OF_PLOTS = 6;

data = javaArray('java.lang.Object',NUMBER_OF_PLOTS,3);
for ct = 1:NUMBER_OF_PLOTS
        data(ct,1) = java.lang.String(sprintf('Plot %d',ct));
        switch this.PlotConfigurations{ct,2}
            case 'None'
                data(ct,2) = java.lang.String('None');
            case 'step'
                data(ct,2) = java.lang.String('Step Response Plot');
            case 'bode'
                data(ct,2) = java.lang.String('Bode Response Plot');
            case 'nichols'
                data(ct,2) = java.lang.String('Nichols Plot');
            case 'nyquist'
                data(ct,2) = java.lang.String('Nyquist Plot');
            case 'pzmap'
                data(ct,2) = java.lang.String('Pole Zero Map');
            case 'iopzmap'
                data(ct,2) = java.lang.String('IO Pole Zero Map');
            case 'impulse'
                data(ct,2) = java.lang.String('Impulse Response');
        end            
        data(ct,3) = java.lang.String(this.PlotConfigurations{ct,3});
end