% DEMO of the use of frequency domain data: iddemofr
echo on

%   This demo illustrates the use of frequency domain data in the toolbox.
%   Frequency domain experimental data are common in many applications. It
%   could be that the data have been collected as frequency response data
%   (frequency functions) from the process using a frequency analyzer. It
%   could also be that it is more practical to work with the input's and
%   output's Fourier transforms, for example to handle periodic or
%   bandlimited data. (A band-limited continuous time signal has no
%   frequency components above the Nyquist frequency.)

echo off
%   Lennart Ljung
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2003/11/11 15:50:28 $
echo on

%   First load some data:

pause % Press a key to continue

load demofr

%   This contains frequency response data at frequencies W, with the
%   amplitude response AMP and the phase response PHA. First look at the
%   data:

pause % Press a key to continue

subplot(211), loglog(W,AMP),title('Amplitude Response')
subplot(212), semilogx(W,PHA),title('Phase Response')

pause % Press a key to continue

%   This experimental data will now be stored as an IDFRD object. First
%   transform amplitude and phase to a complex valued response:

i = sqrt(-1);
zfr = AMP.*exp(i*PHA*pi/180);
Ts = 0.1;
gfr = idfrd(zfr,W,Ts);

%   Ts is the sampling interval of the underlying data. If the data
%   corresponds to continuous time, for example since the input has been
%   band-limited, use Ts = 0.
%   (If you have the control systems toolbox, you could use FRD instead of
%   IDFRD. IDFRD has options for more information, like disturbance spectra
%   and uncertainty measures.)

pause % Press a key to continue

%   The IDFRD object GFR now contains the data, and it can be graphed and
%   analyzed in different ways. (See HELP IDFRD and IDPROPS IDFRD for
%   complete lists of properties.). To plot the data, use

bode(gfr)

pause % Press a key to continue

%   To estimate models, you can now use GFR as a data set with all the
%   commands of the toolbox in a transparent fashion. The only restriction
%   is that noise models cannot be built. This means that for polynomial
%   models only OE (output-error models) apply, and for state-space models,
%   you have to fix K = 0.

m1 = oe(gfr,[2 2 1])

pause % Press a key to continue

ms = pem(gfr) % State-space model with default choice of order

pause % Press a key to continue

compare(gfr,m1,ms)

pause % Press a key to continue

%   The data set ztime is collected from the same system, and validation
%   can also be performed in this data set:

compare(ztime,m1,ms)

pause % Press a key to continue

%   Also all kinds of structured state-space models and arbitrary grey-box
%   models (IDGREY models) can be estimated from frequency response data in
%   an entirely transparent fashion. For example, a simple continuous-time
%   process model (two underdamped poles and a zero):

mp = pem(gfr,'P2U')

pause % Press a key to continue

compare(ztime,mp,ms)

pause % Press a key to continue

%   An important reason to work with frequency response data is that it is
%   easy to condense the information with little loss. The command SPAFRD
%   allows you to compute smoothed response data over limited frequencies,
%   for example with logarithmic spacing. Here is an example where the GFR
%   data is condensed to 100 logarithmically spaced frequency values. With
%   a similar technique, also the original time domain data can be
%   condensed:

pause % Press a key to continue

sgfr = spafdr(gfr)

pause % Press a key to continue

sz = spafdr(ztime);

bode(gfr,sgfr,sz)
%   The Bode plots show that the information in the smoothed data has been 
%   taken well care of. Now, these data records with 100 points can very well 
%   be used for model estimation. e.g

pause % Press a key to continue

msm = oe(sgfr,[2 2 1]);

compare(ztime,msm,m1) % MSM has the same accuracy as M1 (based on 1000 points)

%   It may be that the measurements are available as Fourier transforms of
%   inputs and output. Such frequency domain data from the system are given
%   as the signals Y and U. In loglog plots they look like

pause % Press a key to continue

Wfd = [0:500]'*10*pi/500;
subplot(211),loglog(Wfd,abs(Y)),title('The amplitude of the output')
subplot(212),loglog(Wfd,abs(U)),title('The amplitude of the input')

pause % Press a key to continue

%   The frequency response data is essentially the ratio between Y and U. To
%   collect the frequency domain data as an IDDATA object, do as follows:

ZFD = iddata(Y,U,'ts',0.1,'Domain','Frequency','Freq',Wfd)

pause % Press a key to continue

%   Now, again the frequency domain data set ZFD can be used as data in all
%   estimation routines, just as time domain data and frequency response
%   data:

mf = pem(ZFD);

compare(ztime,mf,m1)

pause % Press a key to continue

%   TRANSFORMATIONS BETWEEN DATA REPRESENTATIONS.

%   Time and frequency domain input-output data sets can be transformed to
%   either domain by using FFT and IFFT. These commands are adapted to 
%   IDDATA objects:

dataf = fft(ztime)

pause % Press a key to continue

datat = ifft(dataf)

%   Time and frequency domain input-output data can be transformed to
%   frequency response data by SPAFDR, SPA and ETFE:

g1 = spafdr(ztime)
g2 = spafdr(ZFD);
bode(g1,g2)

pause % Press a key to continue

%   Frequency response data can also be transformed to more smoothed data
%   (less resolution and less data) by SPAFDR and SPA;

g3 = spafdr(gfr);

%   Frequency response data can be transformed to frequency domain
%   input-output signals by the command IDDATA:

gfd = iddata(g3)

pause % Press a key to continue

%   USING CONTINUOUS TIME DATA TO ESTIMATE CONTINUOUS TIME MODELS.

%   Time domain data can naturally only be stored and dealt with as
%   discrete-time, sampled data. Frequency domain data have the
%   advantage that continuous time data can be represented correctly.
%   Suppose that the underlying continuous time signals have no frequency 
%   information above the Nyquist frequency, e.g. because they are sampled fast,
%   or the input has no frequency component above the Nyquist frequency.
%   Then the Discrete Fourier transforms (DFT) of the data also are the 
%   Fourier transforms of the continuous time signals, at the chosen frequencies.
%   They can therefore be used to directly fit continuous time models. In
%   fact, this is the correct way of using band-limited data for model fit.
%  
%   This will be illustrated by the following example:

pause % Press a key to continue

%   Consider the continuous time system
%               1
%   G(s) = ------------
%          (s^2 + s + 1)

m0 = idpoly(1,1,1,1,[1 1 1],'ts',0)

pause % Press a key to continue

%   Choose an input with low frequency contents that is fast sampled

randn('state',5),rand('state',0)
u = idinput(500,'sine',[0 0.2]);
u = iddata([],u,0.1,'inters','bl'); 

%   0.1 is the sampling interval, and 'bl' indicates that the input is
%   band-limited, i.e. that in continuous time it consists of sinusoids
%   with frequencies below half the sampling frequency. Correct simulation of
%   such a system should be done in the frequency domain:

pause % Press a key to continue

uf = fft(u);
uf.ts = 0; %Denoting that the data is continuous time
yf = sim(m0,uf);

%   add some noise

yf.y = yf.y + 0.05*(randn(size(yf.y))+i*randn(size(yf.y)));

dataf = [yf uf] % This is now a continuous time frequency domain data set.

pause % Press a key to continue

%   Look at the data:

plot(dataf)

pause % Press a key to continue

%   Using dataf for estimation will by default give continuous time models:
%   State-space:

m4 = pem(dataf,2); %Second order

%   For a polynomial model with nb = 1 numerator coefficient and nf = 2
%   estimated denominator coefficients use

nb = 1;
nf = 2;

m5 = oe(dataf,[nb nf]);

pause % Press a key to continue

%   The model:

m5

%   compare step responses with uncertainty of the true system m0 and the
%   models m4 and m5:

step(m0,m4,m5,'sd',3)

pause % Press a key to continue

%   Although it was not necessary in this case, it is generally advised to
%   focus the fit to a limited frequency band (low pass filter the data)
%   when estimating using continuous time data. The system has a bandwidth
%   of about 3 rad/s, and was excited by sinusoids up to 6.2 rad/s. 
%   A reasonable frequency range to focus the fit to is then [0 7] rad/s:
%
m6 = pem(dataf,2,'foc',[0 7]);
m7 = oe(dataf,[1 2],'foc',[0 7]);

step(m0,m6,m7,'sd',3)
