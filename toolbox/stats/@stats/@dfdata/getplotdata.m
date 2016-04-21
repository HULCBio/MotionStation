function [plotx,ploty,ybounds] = getplotdata(ds,ftype,saveInDS)
%GETPLOTDATA Get data for plotting current function type

%   $Revision: 1.1.6.6 $  $Date: 2004/01/24 09:32:34 $
%   Copyright 2003-2004 The MathWorks, Inc.

if nargin<2
    ftype = ds.ftype;
    UseCurrentType = true;
else
    UseCurrentType = isequal(ftype, ds.ftype);
end

% Get required data if not already available
if UseCurrentType && ~isempty(ds.plotx) && ~isempty(ds.ploty) && ...
                                    (~isempty(ds.plotbnds) || nargout<3)
    % Data left over from last time
    plotx = ds.plotx;
    ploty = ds.ploty;
    if nargout>=3
        ybounds = ds.plotbnds;
    end
else
    
    switch(ftype)
    case {'cumhazard' 'hazrate'}
        % The CHF and HRF are based on the Nelson-Aalen estimate, and that's
        % not saved.  We'll call ECDF to get it each time.
        alpha = 1 - ds.conflev;
        [ydata,cens,freq] = getincludeddata(ds,[]); % get data w/o NaNs
        [F,X,Flo,Fup] = ecdf(ydata, 'cens',cens, 'freq',freq, ...
                             'function','cumhazard', 'alpha', alpha);
        ybounds = [Flo, Fup];
        
    otherwise
        % The CDF, SF, PDF, ICDF, and conditional mean are all based on the
        % Kaplan-Meier estimate, and that's (probably) saved from a previous
        % call to ECDF.
        [F,X,ybounds] = getcdfdata(ds);
    end
    
    % Create data of correct type
    switch(ftype)
    case {'cdf' 'survivor' 'cumhazard'}
        % Deal with cdf, survivor, or cumulative hazard in same way
        n = size(X,1);
        ndx = [1:n;1:n];
        ploty = F(ndx(2:end-1));
        plotx = X(ndx(3:end));
        ybounds = ybounds(ndx(2:end-1),:);
        if isequal(ftype,'survivor')
            ploty = 1-ploty;
            ybounds = 1-ybounds;
        end

    case {'pdf' 'hazrate'}
        % Deal with histogram/density or hazard rate choice in the same way
        [ydata,cens,freq] = getincludeddata(ds,[]); % get data w/o NaNs
        [dum,edges] = dfswitchyard('dfhistbins',ydata,cens,freq,ds.binDlgInfo,F,X);
        
        if isequal(ftype,'pdf')
            N = ecdfhist(F,X,'edges',edges);
        else
            % This is in effect what ecdfhist does
            X = X(2:end);
            diffF = diff(F);
            binwidth = diff(edges);
            nbins = length(edges) - 1;
            [ignore,binnum] = histc(X,edges);
            binnum(binnum==nbins+1) = nbins;
            if any(binnum==0)
                diffX(binnum==0) = [];
                diffF(binnum==0) = [];
                binnum(binnum==0) = [];
            end
            N = accumarray([ones(size(binnum)),binnum],diffF,[1,nbins]) ./ binwidth;
        end
        
        n = length(N);
        ploty = [zeros(1,n); N(:)'; N(:)'; zeros(1,n)];
        ploty = ploty(:);
        plotx = [edges(1:end-1); edges(1:end-1); edges(2:end); edges(2:end)];
        plotx = plotx(:);
        ybounds = [];

    case 'icdf'
        % Deal with the inverse cdf
        n = size(X,1);
        ndx = [1:n;1:n];
        plotx = F(ndx(2:end-1));
        ploty = X(ndx(3:end));
        ybounds = [];

%     case 'condmean'
%         % Deal with conditional mean -- this only works for uncensored data
%         n = size(X,1)-1;
%         
%         % mean(X(X > xi))for xi = [-Inf X(2:end)]
%         Y = flipud( cumsum(flipud(X(2:end).*diff(F))) ./ F(2:end) );
%         X = X(2:end);
%         ndx = [1:n;1:n];
%         ploty = Y(ndx(2:end));
%         plotx = X(ndx(1:end-1));
%         ybounds = [];

    otherwise
        error('stats:dfdata:getplotdata:InvalidFunction', 'Invalid function type');
    end

    % Store for next time
    if nargin<3 || saveInDS
        ds.plotx = plotx;
        ds.ploty = ploty;
        ds.plotbnds = ybounds;
    end
end

