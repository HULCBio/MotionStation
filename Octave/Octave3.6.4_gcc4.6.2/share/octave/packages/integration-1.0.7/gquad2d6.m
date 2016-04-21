function vol = gquad6(fun,xlow,xhigh,ylow,yhigh)
%
%usage:  vol = gquad6(fun,xlow,xhigh,ylow,yhigh)
%
%   ==== Six Point by Six Point Double Integral Gauss Formula ====
%
%  This function determines the volume under an externally
%  defined function fun(x,y) between limits xlow and xhigh and
%  ylow and yhigh. The numerical integration is performed using 
%  a gauss integration rule.  The integration is done with a 
%  six point Gauss formula which involves base
%  points bpx, bpy and weight factors wfxy.  The normalized interval
%  of integration for the bp and wf constants is -1 to +1 (in x) and
%  -1 to 1 (in y).  The algorithm is structured in terms of a 
%  parameter nquad = 6 which can be changed to accommodate a different
%  order formula.

%     by Bryce Gardner, Purdue University, Spring 1993
%     modified from gquad6.m by Howard B. Wilson, U. of Alabama, Spring 1990

nquad = 6;
nquadx = nquad;
nquady = nquad;
[bpx,bpy,wfxy] = grule2d(nquadx,nquady);
vol = gquad2d(fun,xlow,xhigh,ylow,yhigh,bpx,bpy,wfxy);

endfunction
