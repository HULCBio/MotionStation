% Simulink: Aerospace model demonstrations and samples.
%
% Demonstration models (.mdl).
%   f14                    - F-14 aircraft model.
%   f14_digital            - F-14 digital autopilot model.
%   aero_dap3dof           - 1969 Lunar Module digital autopilot.
%   aero_six_dof           - Six degrees of freedom motion platform.
%   aero_guidance          - Three degrees of freedom guided missile.
%   aero_guidance_airframe - missile airframe trim and linearise.
%   aero_atc               - air traffic control radar design. 
%   aero_radmod            - Radar tracker.
%   aero_pointer_tracker   - Generating an optical tracker image.

%
% Demonstration models for case studies #1,#2,#3 in the user's guide.
%   f14c - F-14 benchmark, closed-loop form.
%   f14n - F-14 block diagram, alternate form.
%   f14o - F-14 benchmark, open-loop form.
%
%
% Execute the MATLAB command "demo simulink" to see a menu of most demos
% and models in this directory.  The demo menu is also available by
% opening the Demos block in the main Simulink block library (which is 
% displayed by typing "simulink" at the MATLAB command line or by pressing
% the Simulink toolbar icon). 
%
% Demos can also be run by typing their names at the MATLAB command line.
%
% Support routines and data files.
%   aerospace         - Library of flight dynamics components.
%   aero_lin_aero     - linear airframe trim commands
%   aero_dap3dofdata  - Lunar Module constant definitions.
%   aero_phaseplane   - Lunar Module runtime display.
%   f14dat            - F-14 constant definitions.
%   f14dat_digital    - F-14 digital constant definitions.
%   f14actuator       - F-14 digital actuator library.
%   f14autopilot      - F-14 autopilot design model
%   f14pix            - F-14 digital bitmap picture
%   f14controlpix     - F-14 digital bitmap picture
%   f14weather        - F-14 digital bitmap picture
%   aero_guid_dat     - guidance constant definitions.
%   aero_guid_plot    - plot routine for guidance demo.
%   aero_guid_autop   - guidance autopilot gains
%   sanim3dof         - animation S-function (3 degrees of freedom)
%   sanim             - animation S-Function (6 degrees of freedom)
%   aero_preload_atc  - preload routine for air traffic control radar
%   aero_init_atc     - initialization routine for air traffic control radar
%   aero_atcgui       - GUI interface for air traffic control radar
%   aero_atc_callback - callback routine for air traffic control radar GUI
%   aero_extkalman    - Radar tracker extended kalman filter.
%   aero_raddat       - Radar tracker constant definition.
%   aero_radlib       - Radar tracker library of components.
%   aero_radplot      - Radar tracker results presentation.
%   aero_vibrati      - Tracking a moving target vibration simulation.

% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.14 $










