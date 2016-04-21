%CCSFIRDEMO Link to Code Composer Studio(R) IDE demo - Script
%  A script version of the GUI demo.  This is available in the
%  GUI by pressing the button called 'View Script'.  This script
%  is provided to remove the details of the gui.  It illustrates
%  many of the commands available for 'The Link for Code Composer
%  Studio(R)' product
%
% $Revision: 1.11.4.2 $  $Date: 2004/04/08 20:45:32 $
% Copyright 2000-2003 The MathWorks, Inc.

% Opens a link to the board number 0, Processor Number 0
% Use the Matlab command 'CCSBOARDINFO' or the gui
% selection tool 'BOARDPROCSEL' to determine your
% boardnum and procnum in multiple processor configurations.
cc = ccsdsp('boardnum',0,'procnum',0);
cc.timeout = 20;
% Note - For some configuration it is necessary to load a 
% GEL file to configure the EMIF registers at this point.  
% This demo is designed to use internal memory, so in many
% case this is unnecessary.  However, if the target configuration
% requires a GEL file, This can be achieved by creating
% workspace file that can be loaded by Matlab with the 'open' 
% command or manually loading the GEL file from Code Composer.
% open(cc,'ccsfir.wks')  %Optional workspace/GEL load

% Loads the necessary project file.  If necessary, uncomment the
% project file that is appropriate for your DSP processor
demodir = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccsfir');
cd(cc,demodir);
open(cc,'ccsfir_67x.pjt');     % use for c62x/c67x processors
% open(cc,'ccsfir_67xe.pjt');    % use for c62x/c67x processors (big endian)
% open(cc,'ccsfir_64x.pjt');     % use for c64x processors
% open(cc,'ccsfir_64xe.pjt');    % use for c64x processors (big endian)
% open(cc,'ccsfir_55xx.pjt');    % use for c55x processors
% open(cc,'ccsfir_54xx.pjt');    % use for c54x processors
% open(cc,'ccsfir_28xx.pjt');    % use for c28x processors
% open(cc,'ccsfir_27xx.pjt');    % use for c27x processors
% open(cc,'ccsfir_24xx.pjt');    % use for c24x processors
% open(cc,'ccsfir_r1x.pjt');     % use for r1x (ARM7) processors
% open(cc,'ccsfir_r1xe.pjt');    % use for r1x (ARM7) processors (big endian)
% open(cc,'ccsfir_r2x.pjt');     % use for r2x (ARM9) processors
% open(cc,'ccsfir_r2xe.pjt');    % use for r2x (ARM9) processors (big endian)
visible(cc,1);

% After building the necessary program file: 'ccsfir.out', the
% next command will load it into the DSP processor.
reset(cc); pause(0.5);

open(cc,'a67x.out');     % use for c62x/c67x processors
% open(cc,'a67xe.out');    % use for c62x/c67x processors (big endian)
% open(cc,'a64x.out');     % use for c64x processors
% open(cc,'a64xe.out');    % use for c64x processors (big endian)
% open(cc,'a55xx.out');    % use for c55x processors
% open(cc,'a54xx.out');    % use for c54x processors
% open(cc,'a28xx.out');    % use for c28x processors
% open(cc,'a27xx.out');    % use for c27x processors
% open(cc,'a24xx.out');    % use for c24x processors
% open(cc,'ar1x.out');     % use for r1x (ARM7) processors
% open(cc,'ar1xe.out');    % use for r1x (ARM7) processors (big endian)
% open(cc,'ar2x.out');     % use for r2x (ARM9) processors
% open(cc,'ar2xe.out');    % use for r2x (ARM9) processors (big endian)

% Use MATLAB's FIR1 command to create filter coefficients.  Refer
% to the MATLAB Fir filter design tools such as FIR1 to specify
% the desired filter type and response.  In this case, the filter
% is a Low-pass design with a cutoff at at pi/2 radians
ncoeff = 15;
coeff = fir1(ncoeff-1,0.5);

% Query the symbol table of the target to deterine memory location
% of relavant parameters.  The names are taken directly from the
% target source code: ccsfir.c
s = struct('coeff',[]);
s.coeff  = address(cc,'coeff');
s.din    = address(cc,'din');
s.dout   = address(cc,'dout');
s.ncoeff = address(cc,'ncoeff');
s.nbuf   = address(cc,'nbuf');
s.state  = address(cc,'state');

% Scale the coefficients to allow the FIR1 coefficent values (-1 to 1)
% to work properly with the int16 data types (-1*(2^15 - 1) to 2^15). 
cscaling = 2^15;
%
icoeff = int16(cscaling.*coeff);
write(cc,s.coeff,icoeff);
incoeff = int32(ncoeff);
write(cc,s.ncoeff,incoeff);

% Create a block of data values with normal distribution
% Data is scaled for proper operation with int16 data types.
% This scaling is optimized for the input data block
nfrm = 256;
din = randn(nfrm,1);
glim = max([abs(max(din)) abs(min(din))]);
dscale = 2^15/(glim*0.99);  
idin = int16(dscale*din);
write(cc,s.din,idin);
inbuf = int32(nfrm);
write(cc,s.nbuf,inbuf);
write(cc,s.state,int16(zeros(ncoeff+1,1)));

% The supplied target code has been strucutued to halt after running the
% filter.  Thus, execute the target until a halt is detected.
% In some configuration, it may be necessary to insert a breakpoint
% in the code to halt the processor (for example, when using a RTOS
% that runs to idle, but never halts)
restart(cc);
run(cc,'runtohalt');

% Read the filtered data block from the memory of the target
idout = read(cc,s.dout,'int16',nfrm);

% Compute spectra of the filtered data block and compare to
% MATLAB computed estimate of ideal response (using FREQZ)
[sout wsd]= pwelch(double(idout));
sin = pwelch(double(idin));
runningsum = sout./sin;
wplotdb = 10*log10(runningsum);
sco = freqz(coeff,1,wsd);
scodb = 20*log10(abs(sco));
swdb = wsd/pi;

plot(wsdb,wplotdb,'r',swdb,scodb,'b');
xlabel('Frequency (Normalized)');
ylabel('Magnitude (dB)');
title('Iteration: 1');
grid on;

% The following loop will will iteratively filter new blocks of 
% pseudo-random data and average the results.  This will produce 
% an improved estimate of actual filter response.  (statistically)

ntimes = input('Repeat the filter characterization N times to improve the estimate (0=exit): ');

Pxx=zeros(1+nfrm/2,1);   % auto and cross power spectrum for 
Cxy=zeros(1+nfrm/2,1);   % frequency response estimation
for j=1:ntimes

    din = randn(nfrm,1);      % uniformly distributed random number, unit variance
    glim = max([abs(max(din)) abs(min(din))]);  % find largest element
    dscale = 0.99*2^15/(glim); % limit to +/- 0.99
    idin   = int16(dscale*din); 
    write(cc,s.din,idin);
    
    restart(cc);
    run(cc,'runtohalt');
    idout = read(cc,s.dout,'int16',nfrm);
    
    X = fft(hanning(nfrm).*double(idin));   X=X(1:(1+nfrm/2));
    Y = fft(hanning(nfrm).*double(idout')); Y=Y(1:(1+nfrm/2));
    
    Pxx = Pxx+ X.*conj(X);
    Cxy = Cxy+ X.*conj(Y);
    magXfer = 20*log10(abs(Cxy./Pxx));
    wsdn=(0:(nfrm/2))/(nfrm/2); 
    
    plot(swdb,scodb,'b',wsdn,magXfer,'r');
    xlabel('Frequency (Normalized)');
    ylabel('Magnitude (dB)');
    title(['Iteration: ' num2str(j+1)]);
    grid on;
end