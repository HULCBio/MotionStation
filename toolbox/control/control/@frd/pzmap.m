function [pout,z] = pzmap(sys)
%PZMAP  Pole-zero map of LTI models.
%
%   PZMAP(SYS) computes the poles and (transmission) zeros of the
%   LTI model SYS and plots them in the complex plane.  The poles 
%   are plotted as x's and the zeros are plotted as o's.  
%
%   PZMAP(SYS1,SYS2,...) shows the poles and zeros of multiple LTI
%   models SYS1,SYS2,... on a single plot.  You can specify 
%   distinctive colors for each model, as in  
%      pzmap(sys1,'r',sys2,'y',sys3,'g')
%
%   [P,Z] = PZMAP(SYS) returns the poles and zeros of the system 
%   in two column vectors P and Z.  No plot is drawn on the screen.  
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, PZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   See also POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.

%	Clay M. Thompson  7-12-90
%	Revised ACWG 6-21-92, AFP 12-1-95, PG 5-10-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:16:52 $

error('PZMAP is not supported for FRD models.')
