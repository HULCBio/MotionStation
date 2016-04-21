function output = aero_atc_callback( flag )
% AERO_ATC_CALLBACK  Callback functions for conceptual design of ATC RADAR 

%   Stacey Gage, 11/11/99
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/04/10 18:40:13 $

switch flag
case 'bwpw'
    % bandwidth/pulsewidth edit
    set(findobj('Tag','BW_PW_edit'),'Value',str2num(get(findobj('Tag','BW_PW_edit'),'String')));
    output=get(findobj('Tag','BW_PW_edit'),'Value');
    % --- end bandwidth/pulsewidth edit
case 'losses'
    % Losses edit
    set(findobj('Tag','Losses_edit'),'Value',str2num(get(findobj('Tag','Losses_edit'),'String')));
    output=get(findobj('Tag','Losses_edit'),'Value');
    % --- end Losses edit
case 'snr'
    % SNR edit
    set(findobj('Tag','SNR_edit'),'Value',str2num(get(findobj('Tag','SNR_edit'),'String')));
    output=get(findobj('Tag','SNR_edit'),'Value');
    % --- end SNR edit
case 'pt'
    % Transmitter Power edit
    set(findobj('Tag','Trans_Power_edit'),'Value',str2num(get(findobj('Tag','Trans_Power_edit'),'String')));
    output=get(findobj('Tag','Trans_Power_edit'),'Value');
    % --- end Transmitter Power edit
case 'rrange'
    % RADAR Range edit
    set(findobj('Tag','RADAR_Range_edit'),'Value',str2num(get(findobj('Tag','RADAR_Range_edit'),'String')));
    output=get(findobj('Tag','RADAR_Range_edit'),'Value');
    % --- end RADAR Range edit
case 'azsep'
    % Lateral Separation edit
    set(findobj('Tag','AZ_Sep_edit'),'Value',str2num(get(findobj('Tag','AZ_Sep_edit'),'String')));
    output=get(findobj('Tag','AZ_Sep_edit'),'Value');
    % --- end Lateral Separation edit
case 'elsep'
    % Elevation Separation edit
    set(findobj('Tag','EL_Sep_edit'),'Value',str2num(get(findobj('Tag','EL_Sep_edit'),'String')));
    output=get(findobj('Tag','EL_Sep_edit'),'Value');
    % --- end Elevation Separation edit
case 'rres'
    % Range Resolution edit
    set(findobj('Tag','Range_Res_edit'),'Value',str2num(get(findobj('Tag','Range_Res_edit'),'String')));
    output=get(findobj('Tag','Range_Res_edit'),'Value');
    % --- end Range Resolution edit
case 'antennaE'
    % Antenna Efficiency edit
    set(findobj('Tag','Antenna_E_edit'),'Value',str2num(get(findobj('Tag','Antenna_E_edit'),'String')));
    output=get(findobj('Tag','Antenna_E_edit'),'Value');
    % --- end Antenna Efficiency edit
case 'noise'
    % Noise Factor edit
    set(findobj('Tag','Noise_Factor_edit'),'Value',str2num(get(findobj('Tag','Noise_Factor_edit'),'String')));
    output=get(findobj('Tag','Noise_Factor_edit'),'Value');
    % --- end Noise Factor edit
case 'temp'
    % Working Temperature edit
    set(findobj('Tag','Working_Temp_edit'),'Value',str2num(get(findobj('Tag','Working_Temp_edit'),'String')));
    output=get(findobj('Tag','Working_Temp_edit'),'Value');
    % --- end Working Temperature edit
case 'wedit'
    % Wavelength edit
    set(findobj('Tag','Wavelength_edit'),'Value',str2num(get(findobj('Tag','Wavelength_edit'),'String')));
    set(findobj('Tag','Wavelength_Slider'),'Value',get(findobj('Tag','Wavelength_edit'),'Value'));
    
    output=get(findobj('Tag','Wavelength_edit'),'Value');
    % --- end Wavelength edit
case 'wslider'
    % Wavelength Slider
    set(findobj('Tag','Wavelength_edit'),'String',num2str(get(findobj('Tag','Wavelength_Slider'),'Value')));
    set(findobj('Tag','Wavelength_edit'),'Value',str2num(get(findobj('Tag','Wavelength_edit'),'String')));
    
    output=get(findobj('Tag','Wavelength_Slider'),'Value');
    % --- end Wavelength Slider
case 'rband'
    % RADAR Band Select Pop-up Menu
    
    if get(findobj('Tag','RADAR_Band_select'),'Value')==1
        % Value==1 (L Band)
        set(findobj('Tag','RADAR_Band_select'),'Min',0.15);
        set(findobj('Tag','RADAR_Band_select'),'Max',0.3);
    else
        % Value==2 (S Band)
        set(findobj('Tag','RADAR_Band_select'),'Min',0.075);
        set(findobj('Tag','RADAR_Band_select'),'Max',0.15);
    end 
    
    % Wavelength Low text
    set(findobj('Tag','Wavelength_low'),'String',num2str(get(findobj('Tag','RADAR_Band_select'),'Min')));
    % Wavelength High text
    set(findobj('Tag','Wavelength_high'),'String',num2str(get(findobj('Tag','RADAR_Band_select'),'Max')));
    
    % Test Wavelength Slider and edit for values exceeding the Max and Min
    if (get(findobj('Tag','Wavelength_Slider'),'Value')< get(findobj('Tag','RADAR_Band_select'),'Min'))
        set(findobj('Tag','Wavelength_Slider'),'Value',get(findobj('Tag','RADAR_Band_select'),'Min'));
        set(findobj('Tag','Wavelength_edit'),'String',num2str(get(findobj('Tag','Wavelength_Slider'),'Value')));
        set(findobj('Tag','Wavelength_edit'),'Value',str2num(get(findobj('Tag','Wavelength_edit'),'String')));
    elseif  (get(findobj('Tag','Wavelength_Slider'),'Value')> get(findobj('Tag','RADAR_Band_select'),'Max'))
        set(findobj('Tag','Wavelength_Slider'),'Value',get(findobj('Tag','RADAR_Band_select'),'Max'));
        set(findobj('Tag','Wavelength_edit'),'String',num2str(get(findobj('Tag','Wavelength_Slider'),'Value')));
        set(findobj('Tag','Wavelength_edit'),'Value',str2num(get(findobj('Tag','Wavelength_edit'),'String')));
    end  
    % Wavelength Slider (Max/Min)
    set(findobj('Tag','Wavelength_Slider'),'Min',get(findobj('Tag','RADAR_Band_select'),'Min'));
    set(findobj('Tag','Wavelength_Slider'),'Max',get(findobj('Tag','RADAR_Band_select'),'Max'));
    % Wavelength edit (Max/Min)
    set(findobj('Tag','Wavelength_edit'),'Min',get(findobj('Tag','RADAR_Band_select'),'Min'));
    set(findobj('Tag','Wavelength_edit'),'Max',get(findobj('Tag','RADAR_Band_select'),'Max'));
    
    output = get(findobj('Tag','Wavelength_Slider'),'Value');
    
    % --- end RADAR Band Select Pop-up Menu
    
    % --- Weather radio buttons
case 'no precip'
    set(findobj('Tag','No_precip'),'Value',[1])
    set(findobj('Tag','Drizzle'),'Value',[0])
    set(findobj('Tag','Light_precip'),'Value',[0])
    set(findobj('Tag','Moderate_precip'),'Value',[0])
    set(findobj('Tag','Heavy_precip'),'Value',[0])
    output = get(findobj('Tag','No_precip'),'UserData');
case 'drizzle'
    set(findobj('Tag','Drizzle'),'Value',[1])
    set(findobj('Tag','No_precip'),'Value',[0])
    set(findobj('Tag','Light_precip'),'Value',[0])
    set(findobj('Tag','Moderate_precip'),'Value',[0])
    set(findobj('Tag','Heavy_precip'),'Value',[0])
    output = get(findobj('Tag','Drizzle'),'UserData');
case 'light precip'
    set(findobj('Tag','Light_precip'),'Value',[1])
    set(findobj('Tag','Drizzle'),'Value',[0])
    set(findobj('Tag','No_precip'),'Value',[0])
    set(findobj('Tag','Moderate_precip'),'Value',[0])
    set(findobj('Tag','Heavy_precip'),'Value',[0])
    output = get(findobj('Tag','Light_precip'),'UserData');;
case 'moderate precip'
    set(findobj('Tag','Moderate_precip'),'Value',[1])
    set(findobj('Tag','Drizzle'),'Value',[0])
    set(findobj('Tag','No_precip'),'Value',[0])
    set(findobj('Tag','Light_precip'),'Value',[0])
    set(findobj('Tag','Heavy_precip'),'Value',[0])
    output = get(findobj('Tag','Moderate_precip'),'UserData');;
case 'heavy precip'
    set(findobj('Tag','Heavy_precip'),'Value',[1])
    set(findobj('Tag','Drizzle'),'Value',[0])
    set(findobj('Tag','No_precip'),'Value',[0])
    set(findobj('Tag','Light_precip'),'Value',[0])
    set(findobj('Tag','Moderate_precip'),'Value',[0])
    output = get(findobj('Tag','Heavy_precip'),'UserData');;
end
% --- end Weather radio buttons
%--- Update Simulation
set_param('aero_atc','simulationcommand','update')