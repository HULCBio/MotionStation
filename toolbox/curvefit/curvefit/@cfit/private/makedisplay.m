function [line1,line2,line3,line4] = makedisplay(obj,objectname,out,clev)
%

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.12.2.3 $  $Date: 2004/02/01 21:40:55 $

if nargin<4, clev = 0.95; end

line1 = sprintf('%s =', objectname);
line4 = ''; %default
line2c = '';
indep = indepnames(obj);

if (isempty(obj.fittype))
    line2 = xlate('Model: (empty)');
    line3 = xlate('Coefficients: (empty)');
else
    switch category(obj)
    case 'custom'
        if islinear(obj)
            line2a = sprintf('Linear model:\n     ');
        else
            line2a = sprintf('General model:\n     ');
        end
        line2b = fcnstring(objectname,char(indepnames(obj.fittype)),1,formula(obj.fittype));
        if ~isequal(obj.meanx,0) || ~isequal(obj.stdx,1)
            line2c = sprintf('\n       where %s is normalized by mean %0.4g and std %0.4g', ...            
                indep{1}, obj.meanx, obj.stdx);
        end
        try
            le = lasterr;
            ci = confint(obj,clev);
            line3a = sprintf('Coefficients (with %g%% confidence bounds):\n',100*clev);
            line3b = argstring(char(coeffnames(obj.fittype)),obj.coeffValues,...
                               ci,obj.activebounds);
        catch
            line3a = sprintf('Coefficients:\n');
            line3b = argstring(char(coeffnames(obj.fittype)),obj.coeffValues);
            lasterr(le);
        end
        probnamesarray = char(probnames(obj.fittype));
        if ~isempty(probnamesarray)
            line4a = sprintf('Problem parameters:\n');
            line4b = argstring(probnamesarray,obj.probValues);
            line4 = sprintf('%s%s',line4a,line4b);
        end
    case {'spline','interpolant'}
        line2a = sprintf('%s:\n     ',prettyname(obj));
        line2b = fcnstring(objectname,char(indepnames(obj.fittype)),1,formula(obj.fittype));
        line2b = sprintf('%s computed from %s',line2b,char(coeffnames(obj)));
        if ~isequal(obj.meanx,0) || ~isequal(obj.stdx,1)
            line2c = sprintf('\n       where %s is normalized by mean %0.4g and std %0.4g', ...            
                indep{1}, obj.meanx, obj.stdx);
        end
        if nargin>=3 && isfield(out,'p')
            line3a = sprintf('Smoothing parameter:\n');
            line3b = sprintf('       p = %0.8g',out.p);
        else
            line3a = sprintf('Coefficients:\n');
            line3b = argstring(char(coeffnames(obj.fittype)),{xlate('coefficient structure')});
        end
    case 'library'
        if islinear(obj)
            line2a = sprintf('Linear model %s:\n     ',prettyname(obj));
        else
            line2a = sprintf('General model %s:\n     ',prettyname(obj));
        end
        line2b = fcnstring(objectname,char(indepnames(obj.fittype)),1,formula(obj.fittype));
        if ~isequal(obj.meanx,0) || ~isequal(obj.stdx,1)
            line2c = sprintf('\n       where %s is normalized by mean %0.4g and std %0.4g', ...            
                indep{1}, obj.meanx, obj.stdx);
        end
        try
            le = lasterr; 
            ci = confint(obj,clev);
            line3a = sprintf('Coefficients (with %g%% confidence bounds):\n',100*clev);
            line3b = argstring(char(coeffnames(obj.fittype)),obj.coeffValues,...
                               ci,obj.activebounds);
        catch
            line3a = sprintf('Coefficients:\n');
            line3b = argstring(char(coeffnames(obj.fittype)),obj.coeffValues);
            lasterr(le);
        end
        probnamesarray = char(probnames(obj.fittype));
        if ~isempty(probnamesarray)
            line4a = sprintf('Problem parameters:\n');
            line4b = argstring(probnamesarray,obj.probValues);
            line4 = sprintf('%s%s',line4a,line4b);
        end
        
    otherwise
        error('curvefit:cfit:makedisplay:unknownFittype', ...
              'Unknown FITTYPE type.')
    end
    line2 = sprintf('%s%s',line2a,line2b,line2c);
    line3 = sprintf('%s%s',line3a,line3b);
end  

