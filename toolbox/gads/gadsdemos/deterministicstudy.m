% A deterministic study of the GA parameters on performance

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2004/01/16 16:52:44 $

options = gaoptimset;
options.Generations = 3000;
options.TimeLimit = 10;

FitnessFcn = @rastriginsfcn;
GenomeLength = 10;


clf
set(gcf,'double','on','colormap',hot)
shg

% we want to check out a range of crossoverFractions
% rates contains the set we want to evaluate at.
rates = 0:0.2:1;

% since this is a stochastic system, we will do a
% montecarlo study with this many iterations
iterations = 10;

    
results = zeros(iterations,length(rates));
for iteration = 1:iterations
    
    % run the ga once for each element of rates,
    % storing the best score for later comparison
    for i = 1:length(rates)
        options.CrossoverFraction = rates(i);
        [ x,fval,reason] = ga(FitnessFcn,GenomeLength,options);
        results(iteration,i) = fval;
    end

    % plot an image showing in color the best score for each
    % rate value. as iterations progress, there will be more rows in the
    % image, one for each iteration
    subplot(2,1,1)
    imagesc(rates,1:iteration,results(1:iteration,:))
    %colorbar;
    xlabel('CrossoverFraction')
    ylabel('Iteration')
    title(['After ' num2str(iteration), ' iIterations'])
    xlim = get(gca,'xlim');
    p = get(gca,'position');

    % plot the average value for each rate over the iterations. 
    % including error bars at +- one standard deviation
    subplot(2,1,2)
    if(iteration > 1)
        rMean = mean(results(1:iteration,:));
        s = std(results(1:iteration,:));
        errorbar(rates,rMean,s);
    else
        plot(rates,results(1:iteration,:))
    end

    % postion and range the two axis the same.
    p2 = get(gca,'position');
    p2(3) = p(3);
    set(gca,'xlim',xlim,'position',p2);
    grid on
    xlabel('CrossoverFraction')
    ylabel('Score Mean and Std')
    drawnow
end
