% INIT_ATC Initialize conceptual design of ATC RADAR

%   Stacey Gage, 11/11/99
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/04/10 18:40:28 $


%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%  temporary initialization of aircraft range, aircraft cross-section, weather cross-section
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
T_Weather=0;
R_Weather=50;
T_xsection=0;
U_xsection=40;

T_AC=[0:2:2559];

R_AC1=[56*ones(1,20) 54*ones(1,20) 52*ones(1,20) 50*ones(1,20) ...
        48*ones(1,20) 46*ones(1,20) 44*ones(1,20) 42*ones(1,20) 40*ones(1,20) ...
        38*ones(1,20) 36*ones(1,20) 34*ones(1,20) 32*ones(1,20) 30*ones(1,20) ...
        28*ones(1,20) 26*ones(1,20) 24*ones(1,20) 22*ones(1,20) 20*ones(1,20) ...
        20*ones(1,20) 18*ones(1,20) 16*ones(1,20) 14*ones(1,20) 12*ones(1,20) ...
        10*ones(1,20) 8*ones(1,20) 6*ones(1,20) 4*ones(1,20) 2*ones(1,20)]';
R_AC2=[2*ones(1,20) 2*ones(1,20) 2*ones(1,20) 4*ones(1,20) 6*ones(1,20) ...
        8*ones(1,20) 10*ones(1,20) 12*ones(1,20) 14*ones(1,20) 16*ones(1,20) ...
        18*ones(1,20) 20*ones(1,20) 22*ones(1,20) 24*ones(1,20) 26*ones(1,20) ...
        28*ones(1,20) 30*ones(1,20) 30*ones(1,20) 30*ones(1,20) 30*ones(1,20) ...
        32*ones(1,20) 34*ones(1,20) 36*ones(1,20) 38*ones(1,20) 40*ones(1,20) ...
        42*ones(1,20) 44*ones(1,20) 46*ones(1,20) 48*ones(1,20) 50*ones(1,20) ...
        52*ones(1,20) 54*ones(1,20) 54*ones(1,20) 54*ones(1,20) 56*ones(1,20)]';
R_AC=[R_AC1;R_AC2]';

clear R_AC1 R_AC2

Angle_AC=[0*ones(1,20) pi/8*ones(1,20) pi/4*ones(1,20) 0*ones(1,20) -pi/4*ones(1,20) ];
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%  Initialize weather cross-section
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rainfall_bp = [0        0.25    1       4       16];  % rows (mm/Hour)
lambda_bp   = [0.057    0.075   0.1     0.15    0.3]; % columns (m)

sigma_table = [0.0      0.0     0.0     0.0     0.0;... % (m^2/m^3)
        7.5e-10  3.0e-10 8.5e-11 9.0e-12 9.0e-13;...
        6.5e-9   3.6e-9  7.0e-10 7.0e-11 7.0e-12;...
        7.5e-8   4.1e-8  6.8e-9  6.8e-10 6.8e-11;...
        7.0e-7   3.9e-7  8.0e-8  8.0e-9  8.0e-10];

%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%  Pull rest of the initialization from GUI
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
% bandwidth/pulsewidth edit
set(findobj('Tag','BW_PW_edit'),'Value',str2num(get(findobj('Tag','BW_PW_edit'),'String')));
BwPw=get(findobj('Tag','BW_PW_edit'),'Value');
% --- end bandwidth/pulsewidth edit

% Losses edit
set(findobj('Tag','Losses_edit'),'Value',str2num(get(findobj('Tag','Losses_edit'),'String')));
Loss=get(findobj('Tag','Losses_edit'),'Value');
% --- end Losses edit

% SNR edit
set(findobj('Tag','SNR_edit'),'Value',str2num(get(findobj('Tag','SNR_edit'),'String')));
SNR=get(findobj('Tag','SNR_edit'),'Value');
% --- end SNR edit

% Transmitter Power edit
set(findobj('Tag','Trans_Power_edit'),'Value',str2num(get(findobj('Tag','Trans_Power_edit'),'String')));
Pt=get(findobj('Tag','Trans_Power_edit'),'Value');
% --- end Transmitter Power edit

% RADAR Range edit
set(findobj('Tag','RADAR_Range_edit'),'Value',str2num(get(findobj('Tag','RADAR_Range_edit'),'String')));
Rrange=get(findobj('Tag','RADAR_Range_edit'),'Value');
% --- end RADAR Range edit

% Lateral Separation edit
set(findobj('Tag','AZ_Sep_edit'),'Value',str2num(get(findobj('Tag','AZ_Sep_edit'),'String')));
AZ_Sep=get(findobj('Tag','AZ_Sep_edit'),'Value');
% --- end Lateral Separation edit

% Elevation Separation edit
set(findobj('Tag','EL_Sep_edit'),'Value',str2num(get(findobj('Tag','EL_Sep_edit'),'String')));
EL_Sep=get(findobj('Tag','EL_Sep_edit'),'Value');
% --- end Elevation Separation edit

% Range Resolution edit
set(findobj('Tag','Range_Res_edit'),'Value',str2num(get(findobj('Tag','Range_Res_edit'),'String')));
Rres=get(findobj('Tag','Range_Res_edit'),'Value');
% --- end Range Resolution edit

% Antenna Efficiency edit
set(findobj('Tag','Antenna_E_edit'),'Value',str2num(get(findobj('Tag','Antenna_E_edit'),'String')));
E=get(findobj('Tag','Antenna_E_edit'),'Value');
% --- end Antenna Efficiency edit

% Noise Factor edit
set(findobj('Tag','Noise_Factor_edit'),'Value',str2num(get(findobj('Tag','Noise_Factor_edit'),'String')));
Noise=get(findobj('Tag','Noise_Factor_edit'),'Value');
% --- end Noise Factor edit

% Working Temperature edit
set(findobj('Tag','Working_Temp_edit'),'Value',str2num(get(findobj('Tag','Working_Temp_edit'),'String')));
Temp=get(findobj('Tag','Working_Temp_edit'),'Value');
% --- end Working Temperature edit

% Wavelength edit
set(findobj('Tag','Wavelength_edit'),'Value',str2num(get(findobj('Tag','Wavelength_edit'),'String')));
set(findobj('Tag','Wavelength_Slider'),'Value',get(findobj('Tag','Wavelength_edit'),'Value'));

Lambda=get(findobj('Tag','Wavelength_edit'),'Value');
% --- end Wavelength edit

% Weather Radio Buttons
% set values for rainfall rate (mm/hr)
set(findobj('Tag','No_precip'),'UserData',0.0);
set(findobj('Tag','Drizzle'),'UserData',0.25);
set(findobj('Tag','Light_precip'),'UserData',1.0);
set(findobj('Tag','Moderate_precip'),'UserData',4.0);
set(findobj('Tag','Heavy_precip'),'UserData',16.0);


rainfall=get(findobj('Style','radiobutton','Value',[1]),'UserData');

% --- end Weather Radio Buttons
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%  End of initialization
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
