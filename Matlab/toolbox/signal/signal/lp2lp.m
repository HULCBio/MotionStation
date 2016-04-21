function [at,bt,ct,dt] = lp2lp(a,b,c,d,wo)
%LP2LP Lowpass to lowpass analog filter transformation.
%   [NUMT,DENT] = LP2LP(NUM,DEN,Wo) transforms the lowpass filter
%   prototype NUM(s)/DEN(s) with unity cutoff frequency of 1 rad/sec 
%   to a lowpass filter with cutoff frequency Wo (rad/sec).
%   [AT,BT,CT,DT] = LP2LP(A,B,C,D,Wo) does the same when the
%   filter is described in state-space form.
%
%   See also BILINEAR, IMPINVAR, LP2BP, LP2BS and LP2HP

%   Author(s): J.N. Little and G.F. Franklin, 8-4-87
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:12:40 $

if nargin == 3		% Transfer function case
        % handle column vector inputs: convert to rows
        if size(a,2) == 1
            a = a(:).';
        end
        if size(b,2) == 1
            b = b(:).';
        end
	% Transform to state-space
	wo = c;
	[a,b,c,d] = tf2ss(a,b);
end

error(abcdchk(a,b,c,d));
[ma,nb] = size(b);
[mc,ma] = size(c);

% Transform lowpass to lowpass
at = wo*a;
bt = wo*b;
ct = c;
dt = d;

if nargin == 3		% Transfer function case
    % Transform back to transfer function
    [z,k] = tzero(at,bt,ct,dt);
    num = k * poly(z);
    den = poly(at);
    at = num;
    bt = den;
end
