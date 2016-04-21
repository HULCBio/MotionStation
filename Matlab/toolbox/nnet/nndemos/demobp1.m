%% Nonlinear Regression
% A feed-forward network is trained to perform a nonlinear regression between
% spectral components and cholesterol levels.  The final network is analyzed to
% investigate overall performance.
% 
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:26:33 $

%%
% Load in the data file and perform some pre-processing operations.  Normalize
% the inputs and targets so that they have zero mean and unity variance. Also,
% perform a principal component analysis and remove those components which
% account for less than 0.1% of the variation.

load choles_all
[pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
[ptrans,transMat] = prepca(pn,0.001);

%%
% Divide the data up into training, validation and test sets. The testing set
% will start with the second point and take every fourth point. The validation
% set will start with the fourth point and take every fourth point. The training
% set will take the remaining points.

[R,Q] = size(ptrans); iitst = 2:4:Q;
iival = 4:4:Q; iitr = [1:4:Q 3:4:Q];
vv.P = ptrans(:,iival); vv.T = tn(:,iival);
vt.P = ptrans(:,iitst); vt.T = tn(:,iitst);
ptr = ptrans(:,iitr); ttr = tn(:,iitr);

%%
% Create a feedforward network with 5 hidden neurons, 3 output neurons, tansig
% hidden neurons and linear output neurons. Use the Levenberg-Marquardt training
% function - trainlm.  The newff command will also initialize the weights in the
% network.

net = newff(minmax(ptr),[5 3],{'tansig' 'purelin'},'trainlm');

%%
% Train the network using early stopping.  Don't show any results while
% training.

net.trainParam.show = NaN;
[net,tr]=train(net,ptr,ttr,[],[],vv,vt);

%%
% Plot the training, validation and test errors.

plot(tr.epoch,tr.perf,'r',tr.epoch,tr.vperf,':g',tr.epoch,tr.tperf,'-.b');
legend('Training','Validation','Test',-1);
ylabel('Squared Error')

%%
% Simulate the trained network. Convert the output of the network back into the
% original units of the targets. Since the targets were transformed using prestd
% so that the mean was 0 and the standard deviation was 1, we need to use
% poststd (the inverse of prestd) and the original mean and standard deviation
% to transform the network outputs back into the original units.

an = sim(net,ptrans);
a = poststd(an,meant,stdt);

%%
% Plot regression analysis for output element 1.

i = 1;
[m(i),b(i),r(i)] = postreg(a(i,:),t(i,:));

%%
% Plot regression analysis for output element 2.

i = 2;
[m(i),b(i),r(i)] = postreg(a(i,:),t(i,:));

%%
% Plot regression analysis for output element 3.

i = 3;
[m(i),b(i),r(i)] = postreg(a(i,:),t(i,:));



