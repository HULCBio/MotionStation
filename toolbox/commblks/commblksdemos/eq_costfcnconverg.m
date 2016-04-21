function eq_costfcnconverg(w, wRef, sigma2S, sigma2N, numCostFcnPoints, zeroPad,eq)
% EQ_COSTFCNCONVERG plots convergency trajectory of MSE over its cost function. 
%
% If the selected algorithm is the Constant Modulus Algorithm (CMA), this function also
% plots the CMA cost function.
%
% In order to plot the MMSE or the CMA cost function, the number of equalizer coefficients has to be
% equal to 2.  
%
% Syntax:
% eq_costfcnconverg(w, wRef, chCoeff, numTaps, sigma2S, sigma2N, numCostFcnPoints, zeroPad, ic, alg);

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/01/26 23:19:50 $

% Return if the number of parameters is not 2 and the constellation is not BPSK.
if(eq.numTaps == 2 && eq.MConst == 2)
    
    %-- Get equalizer coefficients that minimize MSE
    [w_opt, mmse, delta_opt, mu_max, mu_opt, P, Rn, dv] = eq_getopt(eq.chCoeff.', ...
        eq.numTaps, sigma2S, sigma2N);
    
    if size(w,3)~=1, % Long frames separetely option  
        
        %-- Reshape equalizer taps
        w2 = real(reshape(w,zeroPad,size(w,3),1)); 
        w2 = w2(1:eq.numTaps,:)';
        wRef2 = real(reshape(wRef,zeroPad,size(wRef,3),1)); 
        wRef2 = wRef2(1:eq.numTaps,:)';
                
    else
        %-- Reshape equalizer taps
        w2 = real(reshape(w,length(w)/eq.numTaps,eq.numTaps));
        wRef2 = real(reshape(wRef,length(wRef)/eq.numTaps,eq.numTaps));
    end
        
    %-- Create grid
    range1 = max(max(abs([w2(:,1)-w_opt(1) w2(:,2)-w_opt(2)])))*1.2;
    range2 = max(max(abs([wRef2(:,1)-w_opt(1) wRef2(:,2)-w_opt(2)])))*1.2;
    range= max([range1 range2]);
    t1=linspace(real(w_opt(1))-range,real(w_opt(1))+range, numCostFcnPoints);
    t2=linspace(real(w_opt(2))-range,real(w_opt(2))+range, numCostFcnPoints);    
    [tt1 tt2] = meshgrid(t1, t2);
    
    %-- Compute MSE cost function
    W=[tt1(:) tt2(:)]';
    mseCost = real(sum(conj(W).*((sigma2S*P*P'+Rn)*W),1).'-2*real(sigma2S*W'*(P*dv'))+sigma2S);    
    mseCost = reshape(mseCost,numCostFcnPoints,numCostFcnPoints);
    
    if ~strcmp(eq.alg,'CMA - Constant Modulus Algorithm')
        
        %-- Plot Reference
        figure;
        set(gcf,'position',figposition([17 17 65 69]),'Name','MSE trajectory plot');
        subplot(2,1,1) % Reference
        contour(t1,t2,mseCost, numCostFcnPoints); colorbar; 
        title('MSE Cost Function for Reference Equalizer: LMS - StepSize = 0.01');
        xlabel('w_0'); ylabel('w_1');
        hold on;
        % Plot trajectory
        plot(wRef2(1,1),wRef2(1,2), 'bd','linewidth',2);
        plot(wRef2(:,1),wRef2(:,2), 'rx', wRef2(:,1),wRef2(:,2), 'r-');
        % Plot W_opt labels
        plot(real(w_opt(1)),real(w_opt(2)), 'bo', 'linewidth',2);
        text(w_opt(1), w_opt(2),['\bullet\leftarrow    W_{opt} = [' num2str(w_opt.',2) ']']);
        hold off;
        
        %-- Plot Equalizer
        subplot(2,1,2) 
        contour(t1,t2,mseCost, numCostFcnPoints); colorbar; 
        title(['MSE Cost Function for: ' eq.alg]);
        xlabel('w_0'); ylabel('w_1');                
        hold on;
        % Plot trajectory
        plot(w2(1,1),w2(1,2), 'rd','linewidth',2);
        plot(w2(:,1),w2(:,2), 'bx', w2(:,1),w2(:,2), 'b-');
        % Plot W_opt labels
        plot(real(w_opt(1)),real(w_opt(2)), 'ro', 'linewidth',2);
        text(w_opt(1), w_opt(2),['\bullet\leftarrow    W_{opt} = [' num2str(w_opt.',2) ']']);
        hold off;
        
    else
        %-- Plot Cost Function
        figure;
        set(gcf,'position',figposition([8 9 84 83]),'Name','MSE trajectory plot');
        
        %-- Create grid
        t1=linspace(min(real(w_opt(1)*1.2),-range),max(real(w_opt(1)*1.2),range), numCostFcnPoints);
        t2=linspace(min(real(w_opt(2)*1.2),-range),max(real(w_opt(2)*1.2),range), numCostFcnPoints);
        [tt1 tt2] = meshgrid(t1, t2);
        
        %-- Compute Jcm: CMA Cost function
        W=[tt1(:) tt2(:)]';
        H=conv2(eq.chCoeff,W);       
        Jcm = -2*sum(H.^4,1) + 3*(sum(abs(H).^2,1) + sigma2N*sum(abs(W).^2,1)).^2 - ...
            2*(sum(abs(H).^2,1) + sigma2N*sum(abs(W).^2,1))+1;                    
        Jcm = reshape(Jcm, numCostFcnPoints, numCostFcnPoints);
        
        %-- Compute Jcm for initial conditions
        h_ic = conv2(eq.chCoeff,eq.ic); 
        Jcm_ic = -2*sum(h_ic.^4,1) + 3*(sum(abs(h_ic).^2,1) + sigma2N*sum(abs(eq.ic).^2,1)).^2 - ...
            2*(sum(abs(h_ic).^2,1) + sigma2N*sum(abs(eq.ic).^2,1))+1;      
                
        %-- Plot MSE cost function for reference    
        subplot(2,2,1);
        contour(t1,t2,mseCost, numCostFcnPoints); colorbar; 
        title('MSE Cost Function for Reference: LMS');
        xlabel('w_0'); ylabel('w_1');
        hold on;
        % Plot trajectory
        plot(wRef2(1,1),wRef2(1,2), 'bd','linewidth',2);
        plot(wRef2(:,1),wRef2(:,2), 'rx', wRef2(:,1),wRef2(:,2), 'r-');
        % Plot W_opt text
        plot(real(w_opt(1)),real(w_opt(2)), 'bo', 'linewidth',2 );
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']' '\rightarrow\bullet' ],'color','black',...
                'HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'],'color','black',...
                'HorizontalAlignment','left');
        end
        hold off;
               
        %-- Plot CMA Cost function for reference
        subplot(2,2,2);
        contour(t1,t2,Jcm,linspace(mmse,max(Jcm_ic,1),numCostFcnPoints)); colorbar;
        xlabel('w_0'); ylabel('w_1');
        title('Coefficients Trajectory over CMA Cost Function for Reference');
        % Plot trajectory
        hold on;
        plot(wRef2(1,1),wRef2(1,2), 'bd','linewidth',2);
        plot(wRef2(:,1),wRef2(:,2), 'rx', wRef2(:,1),wRef2(:,2), 'r-');
        % Plot W_opt text
        plot(real(w_opt(1)),real(w_opt(2)), 'bo', 'linewidth',2);       
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']' '\rightarrow\bullet' ],'color','black',...
                'HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'],'color','black',...
                'HorizontalAlignment','left');
        end
        hold off;
        
        %-- Plot MSE Cost function for equalizer
        subplot(2,2,3);
        contour(t1,t2,mseCost, numCostFcnPoints); colorbar; 
        title(['MSE Cost Function for: ' eq.alg]);
        xlabel('w_0'); ylabel('w_1');
        % Plot trajectory
        hold on;
        plot(w2(1,1),w2(1,2), 'bd','linewidth',2);
        plot(w2(:,1),w2(:,2), 'rx', w2(:,1),w2(:,2), 'r-');
        % Plot W_opt text
        plot(real(w_opt(1)),real(w_opt(2)), 'bo', 'linewidth',2 );
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']' '\rightarrow\bullet' ],'color','black',...
                'HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'],'color','black',...
                'HorizontalAlignment','left');
        end
        hold off;
               
        %-- Plot CMA Cost function for equalizer
        subplot(2,2,4);
        contour(t1,t2,Jcm,linspace(mmse,max(Jcm_ic,1),numCostFcnPoints)); colorbar;
        xlabel('w_0'); ylabel('w_1');
        title('Coefficients Trajectory over CMA Cost Function');
        % Plot trajectory
        hold on;
        plot(w2(1,1),w2(1,2), 'bd','linewidth',2);
        plot(w2(:,1),w2(:,2), 'rx', w2(:,1),w2(:,2), 'r-');
        % Plot W_opt text
        plot(real(w_opt(1)),real(w_opt(2)), 'bo', 'linewidth',2);       
        if(w_opt(1)>0)
            text(w_opt(1), w_opt(2),['W_{opt} = [' num2str(w_opt',2) ']' '\rightarrow\bullet' ],'color','black',...
                'HorizontalAlignment','right');
        else
            text(w_opt(1), w_opt(2),['\bullet\leftarrow W_{opt} = [' num2str(w_opt',2) ']'],'color','black',...
                'HorizontalAlignment','left');
        end
        hold off;
    end
end
%[end of eq_costfcnconverg.m]
