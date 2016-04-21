function cmd=mkargs(s,n,f)
%MKARGS Expand input argument created by MKSYS.
%
% CMD=mkargs(TEMP,N,F) is used inside functions for expanding an input
%     argument list which includes systems (as created by MKSYS)
%     and inserting the system matrices in the place of each system.
%     Typical usage involves modifying the list of input arguments in
%     the function definition line to be of the form Z1,Z2,Z3,...,ZN, then
%     inserting two lines immediately after the modified function definition
%     line.   For example,
%            function [x,y,z] = foo(a,b,c)
%     would be replaced by
%            function [x,y,z] = foo(Z1,Z2,Z3)
%            inargs='(a,b,c)';
%            eval(mkargs(inargs,nargin))
%     The optional string TY, if present, specifies the admissible system
%     types for the systems to be encountered in the order in which they
%     are expected, e.g., TY='ss,tss'.
%
%     CAVEAT:  Due to a bug in the way some versions of MATLAB handle
%     the EVAL function, it is critical that the string INARGS not
%     include the names Z1,Z2,etc. in the string INARGS.

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

if nargin<3,f='';end
inarglist=s(find(s=='(')+1:find(s==')')-1);
x1='Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9,Z10,Z11,Z12,Z13,Z14,Z15,Z16,Z17,Z18,Z19,Z20';
x2='Z21,Z22,Z23,Z24,Z25,Z26,Z27,Z28,Z29,Z30,Z31,Z32,Z33,Z34,Z35,Z36,';
x3='Z37,Z38,Z39,Z40,Z41,Z42,Z43,Z44,Z45,Z46,Z47,Z48,Z49,Z50,';
inarglist1=[x1 x2 x3];
ind=find(inarglist1==',');
inarglist1=inarglist1(1:ind(n)-1);
%% WAS cmd = ['[xsflag,nargin,' inarglist ']=mkargs1(''' f ''',' inarglist1 ');' ];
cmd = ['[xsflag,nag1,' inarglist ']=mkargs1(''' f ''',' inarglist1 ');' ];
%
