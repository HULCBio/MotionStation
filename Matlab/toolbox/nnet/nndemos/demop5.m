%% Normalized Perceptron Rule
% A 2-input hard limit neuron is trained to classify 5 input vectors into two
% categories.  Despite the fact that one input vector is much bigger than the
% others, training with LEARNPN is quick.
%
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.16 $  $Date: 2002/04/14 21:27:58 $

%%
% Each of the five column vectors in P defines a 2-element input vectors, and a
% row vector T defines the vector's target categories.  Plot these vectors with
% PLOTPV.

P = [ -0.5 -0.5 +0.3 -0.1 -40; ...
      -0.5 +0.5 -0.5 +1.0 50];
T = [1 1 0 0 1];
plotpv(P,T);


%%
% Note that 4 input vectors have much smaller magnitudes than the fifth vector
% in the upper left of the plot.  The perceptron must properly classify the 5
% input vectors in P into the two categories defined by T.  
% 
% NEWP creates aperceptron.  The first argument specifies the expected ranges of
% two inputs.  The second argument determines that there is only one neuron in
% the layer. LEARNPN is less sensitive to large variations in input vector size
% than LEARNP (the default).

net = newp([-40 1;-1 50],1,'hardlim','learnpn');

%%
% Add the the neuron's initial attempt at classification to the plot.
%
% The initial weights are set to zero, so any input gives the same output and
% the classification line does not even appear on the plot.   Fear not... we are
% going to train it!

hold on
linehandle = plotpc(net.IW{1},net.b{1});

%%
% ADAPT returns a new network object that performs as a better classifier, the
% network output, and the error.  This loop allows the network to adapt for 3
% passes, plots the classification line, and continues until the error is zero.

E = 1;
net.adaptParam.passes = 3;
while (sse(E))
   [net,Y,E] = adapt(net,P,T);
   linehandle = plotpc(net.IW{1},net.b{1},linehandle);
   drawnow;
end

%%
% Note that training with LEARNP took only 3 epochs, while solving the same
% problem with LEARNPN required 32 epochs.  Thus, LEARNPN does much better job
% than LEARNP when there are large variations in input vector size.

%%
% Now SIM can be used to classify any other input vector. For example, classify
% an input vector of [0.7; 1.2].
%
% A plot of this new point with the original training set shows how the network
% performs.  To distinguish it from the training set, color it red.

p = [0.7; 1.2];
a = sim(net,p);
plotpv(p,a);
circle = findobj(gca,'type','line');
set(circle,'Color','red');

%%
% Turn on "hold" so the previous plot is not erased.  Add the training set
% and the classification line to the plot.

hold on;
plotpv(P,T);
plotpc(net.IW{1},net.b{1});
hold off;

%%
% Finally, zoom into the area of interest.
%
% The perceptron correctly classified our new point (in red) as category "zero"
% (represented by a circle) and not a "one" (represented by a plus). The
% perceptron learns properly in much shorter time in spite of the outlier
% (compare with the "Outlier Input Vectors" demo).

axis([-2 2 -2 2]);


