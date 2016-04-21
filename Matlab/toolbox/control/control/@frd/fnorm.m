function fnrm = fnorm(sys,ntype);
%FNORM  Pointwise peak gain of FRD model.
%
%     FNRM = FNORM(SYS) computes, for an FRD model SYS,
%     the frequency response gain at each frequency point.  The 
%     response gain is the 2-norm of the response matrix.  The 
%     output FNRM is an FRD object containing the response 
%     gains across frequencies.
% 
%     FNRM = FNORM(SYS,NTYPE) computes the frequency 
%     response gains using the matrix norm specified by NTYPE.
%     See NORM for valid matrix norms and corresponding 
%     NTYPE values.
%
%   See also NORM, ABS.

%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2003/12/04 01:25:52 $


if nargin < 2
    ntype = 2;
end

if ~(isequal(ntype,1) || isequal(ntype,2) || isequal(ntype,Inf) || isequal(ntype,'fro'))
    error('The only norms available are 1, 2, inf, and ''fro''.')
else
    % Absorb time delays
    if hasdelay(sys)
        sys = delay2z(sys);
    end

    szm = size(sys);

    nf = length(sys.Frequency);
    ResponseData = zeros([1 1 nf szm(3:end)]);

    for k = 1:prod(szm(3:end))
        for i = 1:nf
            ResponseData(1,1,i,k) = norm(sys.ResponseData(:,:,i,k),ntype);
        end
    end
    ts = pvget(sys,'Ts');
    fnrm = frd(ResponseData,sys.Frequency,ts);
end

