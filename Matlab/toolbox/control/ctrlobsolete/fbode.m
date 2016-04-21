function [magout,phase,w] = fbode(varargin)
%FBODE  Bode frequency response for continuous-time linear systems.
%	FBODE(A,B,C,D,IU) produces a Bode plot from the single input IU to
%	all the outputs of the continuous state-space system (A,B,C,D). 
%	IU is an index into the inputs of the system and specifies which 
%	input to use for the Bode response.  The frequency range and 
%	number of points are chosen automatically.  FBODE is a faster, but
%	less accurate, version of BODE.
%
%	FBODE(NUM,DEN) produces the Bode plot for the polynomial transfer
%	function G(s) = NUM(s)/DEN(s) where NUM and DEN contain the 
%	polynomial coefficients in descending powers of s. 
%
%	FBODE(A,B,C,D,IU,W) or FBODE(NUM,DEN,W) uses the user-supplied 
%	frequency vector W which must contain the frequencies, in 
%	radians/sec, at which the Bode response is to be evaluated.  See 
%	LOGSPACE to generate log. spaced frequency vectors.  When invoked
%	with left hand arguments,
%		[MAG,PHASE,W] = FBODE(A,B,C,D,...)
%		[MAG,PHASE,W] = FBODE(NUM,DEN,...) 
%	returns the frequency vector W and matrices MAG and PHASE (in 
%	degrees) with as many columns as outputs and length(W) rows.  No
%	plot is drawn on the screen.  
%	See also: LOGSPACE,SEMILOGX,MARGIN and BODE.

% 	J.N. Little 12-5-88
%	Revised CMT 8-2-90, ACWG 6-21-92
%	Revised A.Potvin 10-1-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.9 $  $Date: 2002/04/10 06:33:32 $

%warning('Use bode instead of fbode.')
no = nargout;
if no,
   [magout,phase,w] = bode(varargin{:});
else
   bode(varargin{:})
end

% end fbode
