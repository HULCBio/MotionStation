function [ic,e_opt,mmse,mseCost,t1,t2] = eq_computecostfcn(chCoeff, numTaps, sigma2S, sigma2N, numCostFcnPoints, range, alg)
% EQ_COMPUTECOSTFCN Computes and plots MMSE Cost function for given
% channel coefficients, signal power and noise level.
%
% This function is called to graphically choose the initial conditions of the
% equalizer coefficients.
%
% In order to plot the MMSE cost function, the number of equalizer coefficients has to be
% equal to 2.  
% 
% If Constant Modulus Algorithm is selected, it also plots the CMA Cost Function.
%
% Syntax:
% [ic,e_opt,mmse,mseCost,t1,t2] = eq_computecostfcn(chCoeff, numTaps, sigma2S, ... 
%      sigma2N, numCostFcnPoints, range, alg);

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/01/26 23:19:49 $

%-- Compute Optimal values of Equalizer Taps
[w_opt, mmse, delta_opt, mu_max, mu_opt, P, Rn, dv] = eq_getopt(chCoeff, ...
    numTaps, sigma2S, sigma2N);
   
switch (alg)
    
    case 'CMA - Constant Modulus Algorithm'
        
        %-- Create grid
        t1=linspace(min(real(w_opt(1)*1.2),-range),max(real(w_opt(1)*1.2),range), numCostFcnPoints);
        t2=linspace(min(real(w_opt(2)*1.2),-range),max(real(w_opt(2)*1.2),range), numCostFcnPoints);
        [tt1 tt2] = meshgrid(t1, t2);
        
        %-- Compute MSE Cost Fucntion
        W=[tt1(:) tt2(:)]';
        mseCost = real(sum(conj(W).*((sigma2S*P*P'+Rn)*W),1).'-2*real(sigma2S*W'*(P*dv'))+sigma2S);
        mseCost = reshape(mseCost,numCostFcnPoints, numCostFcnPoints);
        
        %-- Compute CMA Cost Function
        H=conv2(chCoeff',W);       
        Jcm = -2*sum(H.^4,1) + 3*(sum(abs(H).^2,1) + sigma2N*sum(abs(W).^2,1)).^2 - ...
            2*(sum(abs(H).^2,1) + sigma2N*sum(abs(W).^2,1))+1;                    
        Jcm = reshape(Jcm, numCostFcnPoints, numCostFcnPoints);
        
        %-- Plot Cost Function
        figure;
        subplot(2,1,1)
        contourf(t1,t2,mseCost,linspace(mmse,max(max(mseCost))*0.8,numCostFcnPoints)); colorbar;
        xlabel('w_0'); ylabel('w_1');
        title('MSE Cost function');
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']\rightarrow\bullet' ], ...
                'color','white','HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'], ...
                'color','white','HorizontalAlignment','left');
        end
        
        %-- Plot CM Cost function
        subplot(2,1,2)
        contourf(t1,t2,Jcm,linspace(mmse,max(max(Jcm))*0.5,numCostFcnPoints)); 
        colorbar;
        xlabel('w_0'); ylabel('w_1');
        title('CM Cost function');
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']\rightarrow\bullet' ], ...
                'color','white','HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'], ...
                'color','white','HorizontalAlignment','left');
        end
        
        %-- Set position
        set(gcf,'position',figposition([23 14 58 74]));
        
        % Get Initial Value
        ic = ginput(1)'; 
        if(ic(1)>0)
            text(ic(1), ic(2),['{\itIC = }[' num2str(ic',2) ']\rightarrow\bullet' ], ...
                'color','white','HorizontalAlignment','right');
        else
            text(ic(1), ic(2),['\bullet\leftarrow {\itIC = }[' num2str(ic',2) ']'], ...
                'color','white','HorizontalAlignment','left');
        end           
        
        %-- Close figure after 1 second
        pause(1)
        close(gcf);
        
    otherwise  % Plot only MSE Cost Surface (around mmse)
        
        %-- Create grid around optimal value
        t1=linspace(real(w_opt(1))-range,real(w_opt(1))+range, numCostFcnPoints);
        t2=linspace(real(w_opt(2))-range,real(w_opt(2))+range, numCostFcnPoints);         
        [tt1 tt2] = meshgrid(t1, t2);
        
        %-- Compute MSE Cost function
        W=[tt1(:) tt2(:)]';
        mseCost = real(sum(conj(W).*((sigma2S*P*P'+Rn)*W),1).'-2*real(sigma2S*W'*(P*dv'))+sigma2S);
        mseCost = reshape(mseCost,numCostFcnPoints,numCostFcnPoints);
        
        %-- Plot Cost Function
        figure;
        subplot(1,1,1)
        contourf(t1,t2,mseCost,linspace(mmse,max(max(mseCost)),numCostFcnPoints)); colorbar;
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']\rightarrow\bullet' ], ...
                'color','white','HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'], ...
                'color','white','HorizontalAlignment','left');
        end
        
        xlabel('w_0'); ylabel('w_1');
        title('MSE Cost function');
        
        %-- Get Initial Value
        ic = ginput(1).'; 
        if(ic(1)>w_opt(1)) 
            text(ic(1), ic(2),['{\itIC = [}' num2str(ic',2) ']\rightarrow \bullet' ], ...
                'color','white','HorizontalAlignment','right');
        else
            text(ic(1), ic(2),['\bullet \leftarrow {\itIC = }[' num2str(ic',2) ']'], ...
                'color','white','HorizontalAlignment','left');
        end
        
        %-- Close figure after 1 second
        pause(1)
        close(gcf);
end    

%[end of eq_computecostfcn.m]
