function thd=c2daux(thc,T,method)
%IDPROC/C2DAUX  Converts a continuous time model to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC: The continuous time model, a IDPROC object
%
%   Ts: The sampling interval
%
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewise linear)
%
%    SYSD will be returned as an IDGREY object with the mfile's own sampling.
%
%

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:17:03 $

if nargin < 2
    disp('Usage: SYSD = C2D(SYSC,Ts)')
    disp('       SYSD = C2D(SYSC,Ts,METHOD)')
    disp('       METHOD is one of ''Zoh'' or ''Foh''')
    return
end
if nargin < 3
    try 
        es =pvget(thc,'EstimationInfo');
        method = es.DataInterSample;
    catch
        method = 'zoh';
    end
end
Td = pvget(thc,'Td');Td = Td.value;
nu = size(thc,'nu');
if isnan(Td),Td = 0;end
inpd = floor(Td/T);
newtd = Td-inpd*T;
thc = pvset(thc,'Td',newtd);
thc = idgrey(thc);
filea = pvget(thc,'FileArgument');

if ~iscell(method),method={method};end
if length(method)<nu
    method = repmat(method,1,nu);
end
for ku=1:nu
    if ~any(strcmp(lower(method{ku}),{'foh','zoh'}))
        error('Method must be one of ''foh'' or ''zoh''')
    end  
end
filea{2} = method;  
thc = pvset(thc,'FileArgument',filea);
Told=pvget(thc,'Ts');
if Told>0,error('This model is already  discrete-time!'),end
if T<=0,error('The sampling interval must be positive!'),end
lamscale=1/T;
thd = pvset(thc,'Ts',T,'InputDelay',inpd,'NoiseVariance',pvget(thc,'NoiseVariance')*lamscale);
thd = sethidmo(thd,'c2d',T,method);
 
