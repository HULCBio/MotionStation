function thd=c2daux(thc,T,method)
%IDGREY/C2D  Converts a continuous time model to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC: The continuous time model, an IDGREY object
%
%   Ts: The sampling interval
%
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewuse linear)
%
%   If the property CDmfile='cd' SYSD will be returned as a IDGREY
%   object with the mfile's own sampling.
%
%   Otherwise the discrete time model SYSD is an IDSS object with 
%   'SSParameterization' = 'Free'. Note that the covariance matrix
%   is not translated in that case. 
%

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:16:55 $

if nargin < 2
    disp('Usage: SYSD = C2D(SYSC,Ts)')
    disp('       SYSD = C2D(SYSC,Ts,METHOD)')
    disp('       METHOD is one of ''Zoh'' or ''Foh''')
    return
end
if nargin < 3
    method = 'Zoh';
end

Told=pvget(thc.idmodel,'Ts');
if Told>0,error('This model is already  discrete-time!'),end
if T<=0,error('The sampling interval must be positive!'),end
lamscale=1/T; 
if strcmp(thc.CDmfile,'cd')
    inpd = pvget(thc,'InputDelay');
    if any(inpd)
        if strcmp(thc.MfileName,'procmod') % then the inputdelays will
                                           % be fixed automatically
            thc = pvset(thc,'InputDelay',zeros(size(inpd)));
        else
            thc = pvset(thc,'InputDelay',inpd/T);
        end
    end
    if any(strcmp(pvget(thc,'DisturbanceModel'),{'None','Estimate'}))
        [a,b,c,d,k] = ssdata(thc);
        [ad,bd,cc,dd,kd] = idsample(a,b,c,d,k,T,method);
        ut = pvget(thc,'Utility');
        ut.K = kd;
        thc = uset(thc,ut);
    end
    thd = pvset(thc,'Ts',T);
    thd = sethidmo(thd,'c2d',T,method);
else
    % to secure covariance info is not lost:
    cv = pvget(thc,'CovarianceMatrix');
    if ~ischar(cv)&~isempty(cv)
    setcov(thc);
end
    thd=idss(thc);
    thd = c2daux(thd,T,method);
end

