
open_system('ratelim_harness');
open_system('ratelim_harness/Adjustable Rate Limiter');

t_gain = (0:0.02:2.0)'; u_gain = sin(2*pi*t_gain);
t_pos = [0;2]; u_pos = [1;1]; t_neg = [0;2]; u_neg = [-1;-1];
save('within_lim.mat','t_gain','u_gain','t_pos','u_pos','t_neg','u_neg');
t_gain = [0;2]; u_gain = [0;4]; t_pos = [0;1;1;2]; 
u_pos = [1;1;5;5]*0.02; t_neg = [0;2]; u_neg = [0;0];
save('rising_gain.mat','t_gain','u_gain','t_pos','u_pos','t_neg','u_neg');

testObj1               = cvtest('ratelim_harness/Adjustable Rate Limiter');
testObj1.label         = 'Gain within slew limits';
testObj1.setupCmd      = 'load(''within_lim.mat'');';
testObj1.settings.mcdc = 1;
testObj2               = cvtest('ratelim_harness/Adjustable Rate Limiter');
testObj2.label         = 'Rising gain that temporarily exceeds slew limit';
testObj2.setupCmd      = 'load(''rising_gain.mat'');';
testObj2.settings.mcdc = 1;

[dataObj1,T,X,Y] = cvsim(testObj1,[0 2]);
[dataObj2,T,X,Y] = cvsim(testObj2,[0 2]);

cvhtml('ratelim_report',dataObj1,dataObj2);
cumulative = dataObj1+dataObj2;
cvsave('ratelim_testdata',cumulative);

close_system('ratelim_harness',0);
cvexit;


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/09 19:37:20 $
