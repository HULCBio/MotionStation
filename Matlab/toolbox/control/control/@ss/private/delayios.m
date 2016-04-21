function [a,b,c,d,e,StateName] = delayios(a,b,c,d,e,InputDelays,OutputDelays,StateName)
%DELAYIOS  Delay inputs and outputs of a (single) discrete state-space model.
%
%   [A,B,C,D,E,SN] = DELAYIOS(A,B,C,D,E,IDELAYS,ODELAYS,SN) delays 
%   the inputs and outputs of the discrete-time model (A,B,C,D,E) by 
%   IDELAYS and ODELAYS times the sample period.  IDELAYS and ODELAYS
%   should be vectors of length NU and NY, respectively.  The cell array
%   SN keeps track of statenames.
%
%   See also C2D.

%   Author: P. Gahinet  3-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:03:10 $

na = size(a,1);
ne = size(e,1);
descriptor = (ne>0);
[ny,nu] = size(d);

% Delay inputs
if any(InputDelays),
    % Build a state-space realization of diag(Z.^(-INPUTDELAYS))
    ns = sum(InputDelays);  % number of poles at z=0
    ai = zeros(ns);     bi = zeros(ns,nu);
    ci = zeros(nu,ns);  di = eye(nu);
    
    % Loop over each input channel
    ptr = 0;
    for j=find(InputDelays'),
        k = InputDelays(j);   % j-th channel delayed by z^-k
        ast = ptr+1:ptr+k;    % assigned states
        ai(ast,ast) = diag(ones(1,k-1),1);
        bi(ast,j) = [zeros(k-1,1);1];
        ci(j,ast) = [1,zeros(1,k-1)];
        di(j,j) = 0;
        ptr = ptr+k;
    end
    
    % Series connection with (A,B,C,D) * (AI,BI,CI,DI)
    n1 = size(a,1);
    n2 = size(ai,1);
    a = [a , b * ci ; zeros(n2,n1) , ai];
    b = [b * di ; bi];
    c = [c , d * ci];
    d = d * di;
    if descriptor,
        e = [e zeros(n1,n2);zeros(n2,n1) eye(n2)];
    end
end


% Delay outputs
if any(OutputDelays),
    % Build a state-space realization of diag(Z.^(-OUTPUTDELAYS))
    ns = sum(OutputDelays);
    ao = zeros(ns);     bo = zeros(ns,ny);
    co = zeros(ny,ns);  do = eye(ny);
    
    % Loop over each input channel
    ptr = 0;
    for i=find(OutputDelays'),
        k = OutputDelays(i);   % i-th channel delayed by z^-k
        ast = ptr+1:ptr+k;     % assigned states
        ao(ast,ast) = diag(ones(1,k-1),1);
        bo(ast,i) = [zeros(k-1,1);1];
        co(i,ast) = [1,zeros(1,k-1)];
        do(i,i) = 0;
        ptr = ptr+k;
    end
    
    % Series connection with (AO,BO,CO,DO) * (A,B,C,D)
    % RE: Leave A's states in first position
    n1 = size(a,1);
    n2 = size(ao,1);
    a = [a , zeros(n1,n2) ; bo*c , ao];
    b = [b ; bo * d];
    c = [do * c , co];
    d = do * d;   
    if descriptor,
        e = [e zeros(n1,n2);zeros(n2,n1) eye(n2)];
    end
end


% Update mapping x0_nodelay = G * x0
if nargout>5,
    StateName(na+1:size(a,1),:) = {''};   % state names
end