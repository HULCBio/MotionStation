function eta=mf2th(model,cd,parval,aux,lambda,T)
%MF2TH  Packages user defined model structures into the IDGREY model format.
%   OBSOLETE function. Use IDGREY instead.
%
%   TH = MF2TH(MODEL,CD,PARVAL,AUX,LAMBDA,T)
%
%   TH: The resulting model matrix
%
%   MODEL: The model structure specified as the name of a user-written
%   m-file, which should have the format
%
%           [a,b,c,d,k,x0]=username(parameters,T,AUX)
%
%   Then MODEL='username'. See also Help IDGREY for the format.
%
%   CD: CD='c' if 'username' provides a continuous time model when called
%   with a negative value of T. Else CD = 'd'.
%   PARVAL: The values of the free parameters
%   AUX:   The values of auxiliary parameters in the user-written m-file
%   above.
%   LAMBDA: The covariance matrix of the innovations
%   T: The sampling interval of the data (always a positive number)
%   Default values: AUX=[]; T=1; LAMBDA=identity
%   See also MS2TH, PEM and THETA.

%   L. Ljung 10-2-1990
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:39 $


if nargin<3
   disp('Usage: TH = MF2TH(MODEL,CD,PARAMETERS)')
   disp('       TH = MF2TH(MODEL,CD,PARAMETERS,AUX_PAR,LAMBDA,T)')
   disp('       CD is one of ''c'' or ''d''.')
   return
end

if nargin<6, T=[];end
if nargin<5, lambda=[];end
if nargin<4, aux=[];end
if isempty(T),T=1;end
if isempty(aux),aux=0;end % This is due to a bug in feval (destroys results if
% one argument is [])
if ~isstr(cd),error('The argument cd must be a string'),end
if lower(cd(1))=='c';
   cd1='cd'; T = 0;
else
   cd1 = 'd'; 
end
eta = idgrey(model,parval,cd1,aux,T);
if ~isempty(lambda)
   eta = pvset(eta,'NoiseVariance',lambda);
   end

