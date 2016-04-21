%% Function Functions
% In MATLAB, one function take another as a parameter.  This feature serves a
% wide variety of purposes.  Here we illustrate its use for finding zeros,
% optimization, and integration.
%
% Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 5.14.4.1 $  $Date: 2002/07/10 06:06:17 $

%% The HUMPS Function
% A MATLAB function is an M-file that starts with the keyword function.  This is
% what the function HUMPS looks like:

type humps

%% Plot of HUMPS
% This figure shows a plot of HUMPS in the domain [0,2] using FPLOT.

fplot(@humps,[0,2]);

%% Zero of HUMPS
% The FZERO function finds a zeros of a function near an initial estimate. Our
% guess here for HUMPS is 1.

z = fzero(@humps,1,optimset('Display','off'));
fplot(@humps,[0,2]);                          
hold on;
plot(z,0,'r*');
hold off 

%% Minimum of HUMPS
% FMINBND finds the minimum of a function in a given domain.  Here, we search
% for a minimum for HUMPS in the domain (0.25,1). 
 
m = fminbnd(@humps,0.25,1,optimset('Display','off'));     
fplot(@humps,[0 2]);                                      
hold on; 
plot(m,humps(m),'r*');
hold off
 
%% Integral of HUMPS
% QUAD finds the definite integral of HUMPS in a given domain.  Here it computes
% the area in the domain [0.5, 1].
 
q = quad(@humps,0.5,1);                
fplot(@humps,[0,2]);                   
title(['Area = ',num2str(q)]);
