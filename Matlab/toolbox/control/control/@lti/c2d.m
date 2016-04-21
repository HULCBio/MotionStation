function L = c2d(L,Ts,varargin)
%C2D  Manages LTI properties in C2D conversion
%
%   For Tustin and matched methods,
%      DSYS.LTI = C2D(CSYS.LTI,TS,TOLINT) 
%   sets the LTI properties of the discrete model DSYS produced by
%      DSYS = C2D(CSYS,TS) .
%   The continuous-time delays are scaled by TS and rounded to the
%   nearest integer.
%
%   For the ZOH and FOH methods,
%      DSYS.LTI = C2D(CSYS.LTI,TS,DID,DOD,DIOD) 
%   sets the LTI properties of DSYS = C2D(CSYS,TS).  The arrays
%   DID, DOD, and DIOD specify the discrete-time input, output, 
%   and I/O delays computed during the ZOH and FOH discretization.
%
%   See also TF/C2D.

%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:51:49 $

% Delete Notes and UserData
L.Notes = {};
L.UserData = [];

% Set sample time
L.Ts = Ts;

if nargin==3,
   % Round fractional delays to nearest multiple of Ts for 
   % Tustin and matched methods
   [did,dod,diod] = tmdelays(L.InputDelay/Ts,L.OutputDelay/Ts,...
                             L.ioDelay/Ts,varargin{1});
else
   [did,dod,diod] = deal(varargin{1:3});
end
   
% Set discrete-time delays
L.ioDelay = tdcheck(diod);
L.InputDelay = tdcheck(did);
L.OutputDelay = tdcheck(dod);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [did,dod,diod] = tmdelays(ncid,ncod,nciod,tolint)
%TMDELAYS  Compute discrete-time delays for Tustin and Matched 
%          discretization methods.

% Quick exit if no delays
if ~any(ncid(:)) & ~any(ncod(:)) & ~any(nciod(:)),
   did = ncid;
   dod = ncod;
   diod = nciod;
   return
end

% Equalize dimensionalities
sizes = {size(ncid) , size(ncod) , size(nciod)};
lsizes = cellfun('length',sizes);
[ndmax,i] = max(lsizes);
if ndmax>min(lsizes),
   ncid = repmat(ncid,[1 1 sizes{i}(lsizes(1)+1:lsizes(i))]);
   ncod = repmat(ncod,[1 1 sizes{i}(lsizes(2)+1:lsizes(i))]);
   nciod = repmat(nciod,[1 1 sizes{i}(lsizes(3)+1:lsizes(i))]);
end

% Initialize outputs
did = zeros(size(ncid));
dod = zeros(size(ncod));
diod = zeros(size(nciod));
[ny,nu] = size(nciod(:,:,1));

% Loop over each model
fdelay = 0;
for k=1:prod(sizes{i}(3:end)),
   if any(any(nciod(:,:,k))),
      % Absorb fractional input and output delays into I/O delay matrix.
      did(:,:,k) = floor(ncid(:,:,k)+tolint);  % Discrete input delays
      dod(:,:,k) = floor(ncod(:,:,k)+tolint);  % Discrete output delays
      fid = max(0,ncid(:,:,k)-did(:,:,k));     % Fractional input delays
      fod = max(0,ncod(:,:,k)-dod(:,:,k));     % Fractional output delays
      nciod(:,:,k) = ...
         nciod(:,:,k) + repmat(fid',[ny 1]) + repmat(fod,[1 nu]);
      % Round I/O delays
      diod(:,:,k) = round(nciod(:,:,k));
      fiod = abs(nciod(:,:,k)-diod(:,:,k));
      fdelay = fdelay | any(fiod(:)>2*tolint);
   else
      % Discard fractional input and output delays
      did(:,:,k) = round(ncid(:,:,k));       % Discrete input delays
      dod(:,:,k) = round(ncod(:,:,k));       % Discrete output delays
      fid = abs(ncid(:,:,k)-did(:,:,k));     % Fractional input delays
      fod = abs(ncod(:,:,k)-dod(:,:,k));     % Fractional output delays
      fdelay = fdelay | any(fid(:)>2*tolint) | any(fod(:)>2*tolint);
   end
end

% Issue warning if there were fractional delays
if fdelay,
   warning(sprintf(...
      ['Delays rounded to nearest multiple of the sample time Ts.\n' ...
         '         Use ZOH or FOH methods for more accurate delay handling.']))
end
