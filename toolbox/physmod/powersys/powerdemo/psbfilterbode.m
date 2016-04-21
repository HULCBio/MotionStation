% PSBFILTERBODE plots the impedance versus frequency characteristic of psbfilter demo.

%   Patrice Brunelle, 02-06-97, 25-03-98
%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.2 $

if exist('psbfilter.mat')==0
	[A,B,C,D]=power2sys('psbfilter');
else
	load psbfilter;
end
if exist('bode.m')==2;
   freq=1:1000; w=2*pi*freq;
   [mag,phase]=bode(A,B,C,D,1,w);
   figure;
   subplot(211);
   plot(freq,mag(:,2));
   title('Impedance seen from bus bar');
   ylabel('Z (Ohms)');
   subplot(212);
   plot(freq,phase(:,2));
   ylabel('Phase (degres)');
   xlabel('Frequency (Hz)');
   figure(gcf);
else
   % Control toolbox is not installed.
   warndlg('You need the Control Toolbox to run this application','Frequency Analysis');
end



