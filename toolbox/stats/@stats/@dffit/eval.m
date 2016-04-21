function [y,ylo,yup] = eval(fit,x,ftype,conflev);
%EVAL Evaluate distribution using current function and parameters

%   $Revision: 1.1.6.5 $  $Date: 2004/01/24 09:32:44 $
%   Copyright 2003-2004 The MathWorks, Inc.

ylo = [];
yup = [];
if nargin<3
    ftype = fit.ftype;
end
ds = fit.dshandle;
issmooth = isequal(fit.fittype, 'smooth');
if issmooth
    [ydata,cens,freq] = getincludeddata(ds,fit.exclusionrule);
end

% Get parameters as cell array for convenience
paramlist = num2cell(fit.params);
dist = fit.distspec;

switch(ftype)
case {'pdf' 'hazrate'}
    % Compute pdf or hazard rate, cannot compute bounds for it
    if issmooth
        y = ksdensity(ydata, x, 'cens',cens, 'weight',freq,...
                      'support',fit.support, 'function','pdf',...
                      'kernel',fit.kernel, 'width',fit.bandwidth);
    else
        y = feval(dist.pdffunc,x,paramlist{:});
    end
    
    % For hazard rate, divide pdf by survivor function
    if isequal(ftype, 'hazrate')
        if issmooth
            Y = ksdensity(ydata, x, 'cens',cens, 'weight',freq,...
                          'support',fit.support, 'function','cdf',...
                          'kernel',fit.kernel, 'width',fit.bandwidth);
        else
            Y = feval(dist.cdffunc,x,paramlist{:});
        end
        y = hazratefix(Y,y); % y/(1-Y)
    end

case {'cdf' 'survivor' 'cumhazard' 'probplot'}
    % Compute cdf with or without bounds as required
    if issmooth
        y = ksdensity(ydata, x, 'cens',cens, 'weight',freq,...
                      'support',fit.support, 'function','cdf',...
                      'kernel',fit.kernel, 'width',fit.bandwidth);
    else
        if nargout<=1 % no bounds requested
            y = feval(dist.cdffunc,x,paramlist{:});
        else % bounds requested
            if nargin<4, conflev = fit.conflev; end
            alpha = 1 - conflev;
            [y,ylo,yup] = feval(dist.cdffunc,x,paramlist{:},fit.pcov,alpha);
        end
    end

    % Switch to other functional form if not cdf
    if isequal(ftype, 'survivor')
        y = 1-y;
        temp = yup;
        yup = 1-ylo;
        ylo = 1-temp;
    elseif isequal(ftype, 'cumhazard')
        y = cumhazardfix(y);
        temp = yup;
        yup = cumhazardfix(ylo);
        ylo = cumhazardfix(temp);
    end

case 'icdf'
    % Compute inverse cdf with or without bounds as required
    if issmooth
        y = ksdensity(ydata, x, 'cens',cens, 'weight',freq,...
                      'support',fit.support, 'function','icdf',...
                      'kernel',fit.kernel, 'width',fit.bandwidth);
    else
        if nargout<=1 % no bounds requested
            y = feval(dist.invfunc,x,paramlist{:});
        else % bounds requested
            if nargin<4, conflev = fit.conflev; end
            alpha = 1 - conflev;
            [y,ylo,yup] = feval(dist.invfunc,x,paramlist{:},fit.pcov,alpha);
        end
    end

% case 'condmean'
%     % Compute integral(sum) of x against density(probability)
%     if dist.iscontinuous
% %         muinc = ; % no provision for this yet
%         
%     else
%         % To get sum(t*f(t)) for t=x:Inf, take the sum from 0:Inf and
%         % subtract the sum from 0:(x-1).
%         xmax = floor(max(x));
%         f = feval(dist.pdffunc,(0:xmax),paramlist{:});
%         xf = cumsum((0:xmax)*f);
%         mu = feval(dist.statfunc,paramlist{:});
%         muinc = mu - xf(floor(x));
%     end
%     
%     % Divide by survivor function
%     if issmooth
%         F = ksdensity(ydata, x, 'cens',cens, 'weight',freq,...
%                       'support',fit.support, 'function','cdf',...
%                       'kernel',fit.kernel, 'width',fit.bandwidth);
%     else
%         F = feval(dist.cdffunc,x,paramlist{:});
%     end
%     y = muinc ./ (1 - F);
end

% ---------------------------------------
function y = cumhazardfix(y)
%CUMHAZARDFIX Compute cumulative hazard from cdf, fixing edge cases

y = 1-y;
t = (y>0);
y(t) = -log(y(t));
y(~t) = NaN;

% ---------------------------------------
function y = hazratefix(Y,y)
%HAZRATEFIX Compute hazard rate from pdf and cdf, fixing edge cases

t = (Y<1);
y(t) = y(t) ./ (1-Y(t));
y(~t) = NaN;
