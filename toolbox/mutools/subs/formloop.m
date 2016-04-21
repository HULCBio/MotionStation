% function out = formloop(P,K,sgnfb,sgnff)
%
%	Forms the interconnection structure as shown
%	in the muTools manual, pages 7-2 through 7-3,
%	example on Gain/Phase Margins.
%
%   The default is negative feedback on y2 (sgnfb = 'neg'),
%   and positive feedforward on u1 (sgnff = 'pos').
%
%    Inputs:				Output:
%	P - plant			out - MIMO closed-loop system
%	K - controller
%	sgnfb - feedback sign ('neg' or 'pos')
%	sgnff - feedforward sign ('neg' or 'pos')
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = formloop(P,K,sgnfb,sgnff)
	if nargin < 2
		disp('usage: out = formloop(P,K,''sgnfb'',''sgnff'')')
		return
	end

	[typep,rp,cp,nump] = minfo(P);
	[typek,rk,ck,numk] = minfo(K);

	if strcmp(typep,'syst') & strcmp(typek,'vary')
		error('Incompatible Types');
		return
	elseif strcmp(typep,'vary') & strcmp(typek,'syst')
		error('Incompatible Types');
		return
	elseif rp~=ck | cp~=rk
		error('Incompatible Dimensions');
		return
	end

	ff = 1;
	fb = -1;
	if nargin == 3
		if strcmp(sgnfb,'pos')
			fb = 1;
		end
	elseif nargin==4
		if strcmp(sgnfb,'pos')
				fb = 1;
		end
		if strcmp(sgnff,'neg')
				ff = -1;
		end
	end
	cterm = [zeros(rk,rp+rk) eye(rk);zeros(rp,rp+2*rk); ...
			ff*eye(rp) zeros(rp,2*rk)];
	lterm = [zeros(rk,rp) ; eye(rp) ; fb*eye(rp)];
	rterm = [zeros(rk,rp) eye(rk) eye(rk)];
	ic = madd(cterm,mmult(lterm,P,rterm));
	out = starp(ic,K);
%
%