function [outParams,errorStr]=mf2mf(inParams,inType,outType,tol)
%MF2MF Translates parameters between membership functions.
%   Synopsis
%   outParams = mf2mf(inParams,inType,outType)
%   
%   Description
%   This function translates any built-in membership function type into 
%   another, in terms of its parameter set. mf2mf tries to mimic the symmetry 
%   points for both the new and old membership functions. Occasionally this 
%   translation results in lost information, so that if the output parameters 
%   are translated back into the original membership function type, the 
%   transformed membership function will not look the same as it did 
%   originally. 
%   The input arguments for mf2mf are as follows: 
%   inParams: The parameters of the membership function you are transforming
%   inType: a string name for the type of membership function you are 
%   transforming
%   outType: a string name for the new membership function you are transforming 
%   to.
%   Examples
%   x=0:0.1:5;
%   mfp1 = [1 2 3];
%   mfp2 = mf2mf(mfp1,'gbellmf','trimf');
%   plot(x,gbellmf(x,mfp1),x,trimf(x,mfp2))
%
%   See also DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF,
%   PSIGMF, SIGMF, SMF, TRAPMF, TRIMF, ZMF.

%   Ned Gulley, 6-17-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/14 22:22:43 $

yWaist=0.5;
yShoulder=0.90;
outParams=[];
errorStr=[];
if strcmp(inType,'trimf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=(1-yShoulder)*(inParams(3)-inParams(2))+inParams(2);
    rtWaist=(1-yWaist)*(inParams(3)-inParams(2))+inParams(2);

elseif strcmp(inType,'trapmf') | strcmp(inType,'pimf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=(1-yShoulder)*(inParams(4)-inParams(3))+inParams(3);
    rtWaist=(1-yWaist)*(inParams(4)-inParams(3))+inParams(3);

elseif strcmp(inType,'gaussmf'),
    lftWaist=-abs(inParams(1))*sqrt(-2*log(yWaist))+inParams(2);
    lftShoulder=-abs(inParams(1))*sqrt(-2*log(yShoulder))+inParams(2);
    rtShoulder=2*inParams(2)-lftShoulder;
    rtWaist=2*inParams(2)-lftWaist;

elseif strcmp(inType,'gauss2mf'),
    lftWaist=-abs(inParams(1))*sqrt(-2*log(yWaist))+inParams(2);
    lftShoulder=inParams(2);
    rtShoulder=inParams(4);
    rtWaist=abs(inParams(3))*sqrt(-2*log(yWaist))+inParams(4);

elseif strcmp(inType,'gbellmf'),
    lftWaist=-inParams(1)*((1/yWaist-1)^(1/(2*inParams(2))))+inParams(3);
    lftShoulder=-inParams(1)*((1/yShoulder-1)^(1/(2*inParams(2))))+inParams(3);
    rtShoulder=2*inParams(3)-lftShoulder;
    rtWaist=2*inParams(3)-lftWaist;

elseif strcmp(inType,'sigmf'),
    if inParams(1)>0,
        lftWaist=inParams(2);
        lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
        rtShoulder=2*lftShoulder-lftWaist;
        rtWaist=2*rtShoulder-lftWaist;
    else
        rtWaist=inParams(2);
        rtShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
        lftShoulder=rtShoulder;
        lftWaist=2*lftShoulder-rtWaist;
    end

elseif strcmp(inType,'dsigmf'),
    lftWaist=inParams(2);
    lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    rtWaist=inParams(4);
    rtShoulder=1/inParams(3)*log(1/yShoulder-1)+inParams(4);

elseif strcmp(inType,'psigmf'),
    lftWaist=inParams(2);
    lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    rtWaist=inParams(4);
    rtShoulder=-1/inParams(3)*log(1/yShoulder-1)+inParams(4);

elseif strcmp(inType,'smf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=inParams(2);
    if inParams(1)<inParams(2),
        lftWaist=inParams(1);
        rtWaist=2*inParams(2)-inParams(1);
    else
        lftWaist=2*inParams(2)-inParams(1);
        rtWaist=inParams(1);
    end

elseif strcmp(inType,'zmf'),
    lftShoulder=inParams(2);
    rtShoulder=inParams(2);
    if inParams(1)<inParams(2),
        lftWaist=inParams(1);
        rtWaist=2*inParams(2)-inParams(1);
    else
        lftWaist=2*inParams(2)-inParams(1);
        rtWaist=inParams(1);
    end
else
    % Input MF type is unknown
    outParams=[];
    errorStr=['Cannot translate from input MF type ' inType];
    if nargout<2, error(errorStr); end
    return
end

% We've translated into generalized coordinates, now translate back into
% MF specific parameters...

if nargin<4,
    tol=max(eps, 1e-3*(rtShoulder-lftShoulder));
end


if strcmp(outType,'trimf'),
    center=(rtShoulder+lftShoulder)/2;
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-center center 2*rtWaist-center];

elseif strcmp(outType,'trapmf'),
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-lftShoulder lftShoulder rtShoulder 2*rtWaist-rtShoulder];
    
elseif strcmp(outType,'pimf'),
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-lftShoulder lftShoulder rtShoulder max(tol,2*rtWaist-rtShoulder)];

elseif strcmp(outType,'gbellmf'),
    center=(rtShoulder+lftShoulder)/2;
    a=max(tol,center-lftWaist);
    b=2*a/(max(tol,lftShoulder-lftWaist));
    outParams=[a b center];

elseif strcmp(outType,'gaussmf'),
    center=(rtShoulder+lftShoulder)/2;
    sigma=max(tol,(rtWaist-center)/sqrt(-2*log(yWaist)));
    outParams=[sigma center];

elseif strcmp(outType,'gauss2mf'),
    lftSigma=max(tol,lftShoulder-lftWaist)/sqrt(-2*log(yWaist));
    rtSigma=max(tol,rtWaist-rtShoulder)/sqrt(-2*log(yWaist));
    outParams=[lftSigma lftShoulder rtSigma rtShoulder];

elseif strcmp(outType,'sigmf'),
    center=lftWaist;
    a=-1/max(tol,lftShoulder-center)*log(1/yShoulder-1);
    outParams=[a center];

elseif strcmp(outType,'dsigmf'),
    lftCenter=lftWaist;
    lftA=-1/max(tol,lftShoulder-lftCenter)*log(1/yShoulder-1);
    rtCenter=rtWaist;
    rtA=-1/max(tol,rtCenter-rtShoulder)*log(1/yShoulder-1);
    outParams=[lftA lftCenter rtA rtCenter];

elseif strcmp(outType,'psigmf'),
    lftCenter=lftWaist;
    lftA=-1/max(tol,lftShoulder-lftCenter)*log(1/yShoulder-1);
    rtCenter=rtWaist;
    rtA=1/max(tol,rtCenter-rtShoulder)*log(1/yShoulder-1);
    outParams=[lftA lftCenter rtA rtCenter];


elseif strcmp(outType,'smf'),
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-lftShoulder lftShoulder];

elseif strcmp(outType,'zmf'),
    % Assumes yWaist=0.5
    outParams=[rtShoulder 2*rtWaist-rtShoulder];

else
    % Output MF type is unknown
    outParams=[];
    errorStr=['Cannot translate to output MF type ' outType];
    if nargout<2, error(errorStr); end
    return
end

outParams=eval(mat2str(outParams,4));
