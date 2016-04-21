function sys = feedback(sys1,sys2,varargin)
%FEEDBACK  Feedback connection of two LTI models. 
%
%   SYS = FEEDBACK(SYS1,SYS2) computes an LTI model SYS for
%   the closed-loop feedback system
%
%          u --->O---->[ SYS1 ]----+---> y
%                |                 |           y = SYS * u
%                +-----[ SYS2 ]<---+
%
%   Negative feedback is assumed and the resulting system SYS 
%   maps u to y.  To apply positive feedback, use the syntax
%   SYS = FEEDBACK(SYS1,SYS2,+1).
%
%   SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) builds the more
%   general feedback interconnection:
%                      +--------+
%          v --------->|        |--------> z
%                      |  SYS1  |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[  SYS2  ]<---+
%
%   The vector FEEDIN contains indices into the input vector of SYS1
%   and specifies which inputs u are involved in the feedback loop.
%   Similarly, FEEDOUT specifies which outputs y of SYS1 are used for
%   feedback.  If SIGN=1 then positive feedback is used.  If SIGN=-1 
%   or SIGN is omitted, then negative feedback is used.  In all cases,
%   the resulting LTI model SYS has the same inputs and outputs as SYS1 
%   (with their order preserved).
%
%   If SYS1 and SYS2 are arrays of LTI models, FEEDBACK returns an LTI
%   array SYS of the same dimensions where 
%      SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k)) .
%
%   See also LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.

%   P. Gahinet  6-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.22.4.1 $  $Date: 2002/11/11 22:22:11 $

ni = nargin;
error(nargchk(2,5,ni));

% Make sure both arguments are TF
sys1 = tf(sys1);
sys2 = tf(sys2);
size1 = size(sys1.num);
size2 = size(sys2.num);
if length(size1)<length(size2)
	asize = size2(3:end);
else
	asize = size1(3:end);
end

% Handle various cases. Use try/catch to keep errors at top level
try
	if all(size1(1:2)==1) & all(size2(1:2)==1),
		% SISO loop
		sys = sys1;
		sys.num = cell([1 1 asize]);
		sys.den = cell([1 1 asize]);

		% Get SIGN
		switch ni
		case 2
			sign = -1;
		case 3
			sign = varargin{1};
		case 4 
			sign = -1;
		end
		
		% LTI inheritance
		sys.lti = feedback(sys1.lti,sys2.lti,[isstatic(sys1) , isstatic(sys2)]);
		
		% Check for time delays
		Ts = getst(sys.lti);
		if hasdelay(sys1) | hasdelay(sys2),
			if Ts, 
				% Discrete-time case: map discrete delays to poles at z=0
				sys1.lti = pvset(sys1.lti,'Ts',Ts);
				sys1 = delay2z(sys1);
				sys2.lti = pvset(sys2.lti,'Ts',Ts);
				sys2 = delay2z(sys2);
			else
				error('FEEDBACK cannot handle time delays.')
			end
		end
		
		% Create output
		len1 = prod(size1);
		len2 = prod(size2);
		for k=1:prod(asize),
			k1 = min(k,len1);
			k2 = min(k,len2);
			numer = conv(sys1.num{k1},sys2.den{k2});
			denom = conv(sys1.den{k1},sys2.den{k2}) - ...
				sign * conv(sys1.num{k1},sys2.num{k2});
			if ~any(denom)
				error('Algebraic loop: feedback interconnection is non causal.')
			else
            % Eliminate leading zeros 
            % cf feedback(tf(5,[1 2 5]),tf([1 3],1))
				[sys.num{k},sys.den{k}] = ndorder(numer,denom);
			end
		end
		
	elseif isproper(sys1) & isproper(sys2)
		% MIMO/proper case
		sys = tf(feedback(ss(sys1),ss(sys2),varargin{:}));   
		
	else
		error('FEEDBACK cannot handle improper MIMO transfer functions.')  
	end
	
catch
	rethrow(lasterror)
end


% Variable name 
sys.Variable = varpick(sys1.Variable,sys2.Variable,getst(sys.lti));