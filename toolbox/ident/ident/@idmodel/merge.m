function [th1,xi] = merge(varargin)
%MERGE Merge two models.
%
%   M = merge(M1,M2,M3,...)
%
%   The models Mi must be of the same model structure.
%   M is the statistical average of Mi and delivered in
%   the same format.
%
%   When two models are merged
%   [M, xi] = merge(M1,M2)  returns a test variable xi.  
%   It is chi^2 distributed with  n = dim(Mi.ParameterVector) degrees
%   of freedom if the parameters of M1 and M2 have the same means.
%   A large value of xi thus indicates that it might be questionable
%   to merge the models.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:17:30 $


th1 = varargin{1};
ut1 = pvget(th1,'Utility');

switch class(th1)
case 'idgrey'   
case 'idpoly'
case 'idarx'
case 'idss'
    %th1 = pvset(th1,'InitialState','z');
    if strcmp(pvget(th1,'SSParameterization'),'Free')
        try
            th = ut1.Pmodel;
        catch
            th = [];
        end
        %    error(sprintf(['Models with free state-space parametrizations must be\n',...
        %         'estimated with covariance.']))
        if isempty(th)
            th1 = pvset(th1,'SSParameterization','Canonical');
        else
            th1 = th;
           
        end
        %th1 = pvset(th1,'InitialState','z');
    end
end
    %if ~strcmp(class(th1),'idpoly')
    try
        polymod1 = ut1.Idpoly;
    catch
        polymod1 = [];
    end
    %end
    for kj = 2:length(varargin)
        th2 = varargin{kj};
        ut2 = pvget(th2,'Utility');
        if isa(th2,'idss')&strcmp(pvget(th2,'SSParameterization'),'Free')   
            try
                th = ut2.Pmodel;
            catch
                th = [];
                %error(sprintf(['Models with free state-space parametrizations must be\n',...
                %     'estimated with covariance.']))
            end
            if isempty(th)
                th2 = pvset(th2,'SSParameterization','Canonical');
            else
                th2 = th;
            end
        end
        %  if ~strcmp(class(th2),'idpoly')
        try
            polymod2 = ut2.Idpoly;
        catch
            polymod2 = [];
        end
        % end
        if isa(th2,'idss')
         %   th2 = pvset(th2,'InitialState','z');
        end
        error(samstruc(th2,th1))
        p1 = th1.ParameterVector;
        p2 = th2.ParameterVector;
        P1 = th1.CovarianceMatrix;
        P2 = th2.CovarianceMatrix;
        if norm(P1)==0|norm(P2)==0|ischar(P1)|ischar(P2)
            P1 = eye(length(p1)); P2 = P1;
            warning('MERGE cannot be used unless the covariance matrices are defined.')
        end
        
        if length(p1)~=length(p2)
            error('The models must have the same orders.')
        end  
        iP1=inv(P1);iP2=inv(P2);
        if length(iP1)~=length(iP2) % This could happen depending on initial
            % conditions
            mi = min(length(iP1),length(iP2));
            iP1 = iP1(1:mi,1:mi);
            iP2 = iP2(1:mi,1:mi);
        end
        P=inv(iP1+iP2);
        th1.CovarianceMatrix = P;
        th1.ParameterVector = P*(iP1*p1+iP2*p2);
        testvar= (p1-p2)'*inv(inv(iP1)+inv(iP2))*(p1-p2)/length(p1);
        if testvar>4 & nargout<2
            disp('INFORMATION: The merged models show significant differences.')
        end
        xi = testvar*length(p1);
        if ~isempty(polymod1)&~isempty(polymod2)
            for kk = 1:length(polymod1)
                polymod1{kk} = merge(polymod1{kk},polymod2{kk});
            end
            
        else
            polymod1 = [];
        end
        ut1.Idpoly = polymod1;
        th1.Utility = ut1; 
    end
    