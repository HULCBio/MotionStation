%PRELOAD_FEEDBACK  Define default parameters for Fixed Point Feedback Demo
%  
% Called by fxpdemo_feedback.mdl and fxpdemo_code_only.mdl


% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.11 $  
% $Date: 2002/04/10 19:02:43 $

% specify natural frequency and damping ratio of plant
wn = 20;
zeta = 0.5;

% define numerator and denominator of plant TF
pnum = 4 * wn^2;
pden =     [1 2*zeta*wn wn^2];
pden = conv( pden, [ 1/wn 1 ] );

% calc dc gain of plant TF
plant_dc_gain = polyval(pnum,0)/polyval(pden,0);

% set desired closed loop bandwidth
des_cl_band = 0.8*wn;

% define compensator denominator
%   add poles relative the desired closed loop bandwidth     
%   ie set higher order rollofff beyond crossover
kk=5;
den=poly( [ -des_cl_band*kk; -des_cl_band*kk; -2*des_cl_band*kk ] );
%
%  normalize the contribution of the current denominator
%    so that it does NOT affect the DC gain
%
den=den/polyval(den,0);
%
%  add an integrator, to give good DC tracking
%    this pole will also be responsible for the
%    one pole rolloff at crossover
%
den=conv(den,[1 0]);

% define compensator numerator
%    cancel all stable plant poles with compensator zeros
num=pden;
%
% adjust the compensator gain such that the open loop TF
%  crosses over at the frequency desired for the closed loop bandwidth
%
jay=sqrt(-1);
ss = jay*des_cl_band/100;
num=num*abs(polyval(den,ss)/polyval(num,ss))*100/plant_dc_gain;

%
% calculate and plot the frequency responses of the plant and
%  of the open loop TF
%
if 0
    w=logspace(-1,3,1001).';
    jw=jay*w;
    vplant = polyval(pnum,jw)./polyval(pden,jw);
    vol = polyval(conv(num,pnum),jw)./polyval(conv(den,pden),jw);
    
    figure(1)
    
    subplot(2,1,1)
    loglog(w,abs(vplant),'r--',w,abs(vol),'g-')
    title('Bode Plots: Plant Only (red--) and Open Loop (green-)')
    xlabel('Freq (rad/sec)')
    ylabel('Magnitude')
    %yaxis([1e-4 1e4])
    grid on
    
    subplot(2,1,2)
    semilogx(w,180/pi*unwrap(angle(vplant)),'r--',w,180/pi*unwrap(angle(vol)),'g-')
    xlabel('Freq (rad/sec)')
    ylabel('Phase')
    grid on
end

%
% define details regarding the 
%   discrete time and fixed point implementation
%   of the ideal design computed above
%

% set the sample rate
tsamp = 0.01;

% convert continuous time design to discrete time
%
% change 0 below to a 1, if it is desired to
% experment with the design and to have the
% continuous design automatically converted to discrete time.
%
if 0 & ( exist('c2d') == 2 )
    %
    % compute the discrete time TF using
    %   the control toolbox
    %
    csys = tf(num,den);
    dsys=c2d(csys,tsamp,'tustin')
    [dnum,dden]=tfdata(dsys);
    dnum=dnum{1};
    dden=dden{1};
else
    %
    % handle case when control toolbox
    %  is not available
    %
%    disp('Using stored coefficients for the discrete time controller.')
%    disp('These are valid only if the original design has not been changed.')
    dnum = [
        8.859903814981437e-001
       -1.419326114832407e+000
       -2.858969781410884e-001
        1.425131129616998e+000
       -5.942883885724647e-001
       ].';
    dden = [
        1.000000000000000e+000
       -1.968253968253968e+000
        1.247165532879818e+000
       -2.993197278911561e-001
        2.040816326530606e-002
        ].';
end

%
% specify the base type for the embedded processor to be used
%  also specify the typically larger size the is
%  readily available in the processors CPU of intermediate results
BaseType = sfix(16);
AccumType = sfix(32);
