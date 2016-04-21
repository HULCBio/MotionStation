function [guessTR,guessE,logliks] = hmmtrain(seqs,guessTR,guessE,varargin)
%HMMTRAIN maximum likelihood estimator of model parameters for an HMM.
%   [ESTTR, ESTEMIT] = HMMTRAIN(SEQS,TRGUESS,EMITGUESS) estimates the
%   transition and emission probabilities for a Hidden Markov Model from
%   sequences, SEQS, using the Baum-Welch algorithm. SEQS can be a single
%   sequence or a cell array of sequences. TRGUESS and EMITGUESS are
%   initial estimates of the transition and emission probability matrices.
%   TRGUESS(I,J) is the estimated probability of transition from state I to
%   state J. EMITGUESS(K,SYM) is the estimated probability that symbol SYM
%   is emitted from state K.
%
%   HMMTRAIN(...,'ALGORITHM',ALGORITHM) allows you to select the
%   training algorithm. ALGORITHM can be either 'BaumWelch' or 'Viterbi'.
%   The default algorithm is BaumWelch.
%
%   HMMTRAIN(...,'SYMBOLS',SYMBOLS) allows you to specify the symbols
%   that are emitted. SYMBOLS can be a numeric array or a cell array of the
%   names of the symbols.  The default symbols are integers 1 through M,
%   where N is the number of possible emissions.
%
%   HMMTRAIN(...,'TOLERANCE',TOL) allows you to specify the tolerance
%   used for testing convergence of the iterative estimation process.
%   The default tolerance is 1e-6.
%
%   HMMTRAIN(...,'MAXITERATIONS',MAXITER) allows you to specify the
%   maximum number of iterations for the estimation process. The default
%   number of iterations is 500.
%
%   HMMTRAIN(...,'VERBOSE',true) reports the status of the algorithm at
%   each iteration.
%
%   HMMTRAIN(...,'PSEUDOEMISSIONS',PSEUDOE) allows you to specify
%   pseudocount emission values for the Viterbi training algorithm.
%
%   HMMTRAIN(...,'PSEUDOTRANSITIONS',PSEUDOTR) allows you to specify
%   pseudocount transition values for the Viterbi training algorithm.
%
%   If the states corresponding to the sequences are known then use
%   HMMESTIMATE to estimate the model parameters.
%
%   This function always starts the model in state 1 and then makes a
%   transition to the first step using the probabilities in the first row
%   of the transition matrix. So in the example given below, the first
%   element of the output states will be 1 with probability 0.95 and 2 with
%   probability .05.
%
%   Examples:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       seq1 = hmmgenerate(100,tr,e);
%       seq2 = hmmgenerate(200,tr,e);
%       seqs = {seq1,seq2};
%       [estTR, estE] = hmmtrain(seqs,tr,e);
%
%   See also  HMMGENERATE, HMMDECODE, HMMESTIMATE, HMMVITERBI.

%   Reference: Biological Sequence Analysis, Durbin, Eddy, Krogh, and
%   Mitchison, Cambridge University Press, 1998.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2004/01/24 09:34:05 $

tol = 1e-6;
trtol = tol;
etol = tol;
maxiter = 500;
pseudoEcounts = false;
pseudoTRcounts = false;
verbose = false;
[numStates, checkTr] = size(guessTR);
if checkTr ~= numStates
    error('stats:hmmtrain:BadTransitions','TRANSITION matrix must be square.');
end

% number of rows of e must be same as number of states

[checkE, numEmissions] = size(guessE);
if checkE ~= numStates
    error('stats:hmmtrain:InputSizeMismatch',...
        'EMISSIONS matrix must have the same number of rows as TRANSITIONS.');
end
if (numStates ==0 || numEmissions == 0)
    guessTR = [];
    guessE = [];
    return
end

baumwelch = true;

if nargin > 3
    if rem(nargin,2)== 0
        error('stats:hmmtrain:WrongNumberArgs',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'symbols','tolerance','pseudoemissions','pseudotransitions','maxiterations','verbose','algorithm','trtol','etol'};
    for j=1:2:nargin-3
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('stats:hmmtrain:BadParameter',...
                'Unknown parameter name:  %s.',pname);
        elseif length(k)>1
            error('stats:hmmtrain:BadParameter',...
                'Ambiguous parameter name:  %s.',pname);
        else
            switch(k)
                case 1  % symbols
                    symbols = pval;
                    numSymbolNames = numel(symbols);
                    if length(symbols) ~= numSymbolNames
                        error('stats:hmmtrain:BadSymbols',...
                            'SYMBOLS must be a vector.');
                    end
                    if numSymbolNames ~= numEmissions
                        error('stats:hmmtrain:BadSymbols',...
                            'Number of Symbols must match number of emissions.');
                    end

                    % deal with a single sequence first
                    if ischar(seqs{1})
                        [dummy, seqs]  = ismember(seqs,symbols);
                    else  % now deal with a cell array of sequences
                        numSeqs = numel(seqs);
                        newSeqs = cell(numSeqs,1);
                        for count = 1:numSeqs
                            [dummy, newSeqs{count}] = ismember(seqs{count},symbols);
                        end
                        seqs = newSeqs;
                    end
                    %
                case 2  % tol
                    tol = pval;
                    trtol = tol;
                    etol = tol;
                case 3  % Pseudocounts
                    pseudoE = pval;
                    [rows, cols] = size(pseudoE);
                    if  rows < numStates
                        error('stats:hmmtrain:InputSizeMismatch',...
                            'There are more states in GUESSTR than in PSEUDOE.');
                    end
                    if  cols < numEmissions
                        error('stats:hmmtrain:InputSizeMismatch',...
                            'There are more symbols in SEQ than in PSEUDOE.');
                    end
                    numStates = rows;
                    numEmissions = cols;
                    pseudoEcounts = true;

                case 4  % Pseudocount transitions
                    pseudoTR = pval;
                    [rows, cols] = size(pseudoTR);
                    if rows ~= cols
                        error('stats:hmmtrain:BadPseudoTransitions',...
                            'PSEUDOTRANSITIONS matrix must be square.');
                    end
                    if  rows < numStates
                        error('stats:hmmtrain:InputSizeMismatch',...
                            'There are more states in GUESSTR than in PSEUDOTR.');
                    end
                    numStates = rows;
                    pseudoTRcounts = true;
                case 5 % max iterations
                    maxiter = pval;
                case 6 % verbose
                    if islogical(pval) || isnumeric(pval)
                        verbose = pval;
                    else
                        if ischar(pval)
                            k = strmatch(lower(pval), {'on','true','yes'});
                            verbose = true;
                        end
                    end
                case 7 % algorithm
                    k = strmatch(lower(pval), {'baumwelch','viterbi'});
                    if isempty(k)
                        error('stats:hmmtrain:BadAlgorithm',...
                            'Unknown algorithm name:  %s.',pval);
                    end
                    if k == 2
                        baumwelch = false;
                    end
                case 8 %transtion tolerance
                    trtol = pval;
                case 9 % emission tolerance
                    etol = pval;
            end
        end
    end
end
if isnumeric(seqs)
    [numSeqs, seqLength] = size(seqs);
    cellflag = false;
elseif iscell(seqs)
    numSeqs = numel(seqs);
    cellflag = true;
else
    error('stats:hmmtrain:BadSequence',...
        'Seqs must be cell array or numerical array.');
end

% inititalize the counters
TR = zeros(size(guessTR));

if ~pseudoTRcounts
    pseudoTR = TR;
end
E = zeros(numStates,numEmissions);

if ~pseudoEcounts
    pseudoE = E;
end

converged = false;
loglik = 1; % loglik is the log likelihood of all sequences given the TR and E
logliks = zeros(1,maxiter);
for iteration = 1:maxiter
    oldLL = loglik;
    loglik = 0;
    oldGuessE = guessE;
    oldGuessTR = guessTR;
    for count = 1:numSeqs
        if cellflag
            seq = seqs{count};
            seqLength = length(seq);
        else
            seq = seqs(count,:);
        end

        if baumwelch   % Baum-Welch training
            % get the scaled forward and backward probabilities
            [p,logPseq,fs,bs,scale] = hmmdecode(seq,guessTR,guessE);
            loglik = loglik + logPseq;
            % avoid log zero warnings
            w = warning('off', 'MATLAB:log:logOfZero');
            logf = log(fs);
            logb = log(bs);
            logGE = log(guessE);
            logGTR = log(guessTR);
            warning(w);
            % f and b start at 0 so offset seq by one
            seq = [0 seq];

            for k = 1:numStates
                for l = 1:numStates
                    for i = 1:seqLength
                        TR(k,l) = TR(k,l) + exp( logf(k,i) + logGTR(k,l) + logGE(l,seq(i+1)) + logb(l,i+1))./scale(i+1);
                    end
                end
            end
            for k = 1:numStates
                for i = 1:numEmissions
                    pos = find(seq == i);
                    E(k,i) = E(k,i) + sum(exp(logf(k,pos)+logb(k,pos)));
                end
            end
        else  % Viterbi training
            [estimatedStates,logPseq]  = hmmviterbi(seq,guessTR,guessE);
            loglik = loglik + logPseq;
            % w = warning('off');
            [iterTR, iterE] = hmmestimate(seq,estimatedStates,'pseudoe',pseudoE,'pseudoTR',pseudoTR);
            %warning(w);
            % deal with any possible NaN values
            iterTR(isnan(iterTR)) = 0;
            iterE(isnan(iterE)) = 0;

            TR = TR + iterTR;
            E = E + iterE;
        end
    end
    totalEmissions = sum(E,2);
    totalTransitions = sum(TR,2);

    % avoid divide by zero warnings
    if ~baumwelch
        w = warning('off','MATLAB:divideByZero');
    end

    guessE = E./(repmat(totalEmissions,1,numEmissions));
    guessTR  = TR./(repmat(totalTransitions,1,numStates));
    if ~baumwelch
        warning(w);
        guessTR(isnan(guessTR)) = 0;
        guessE(isnan(guessE)) = 0;
    end

    if verbose
        if iteration == 1
            disp(sprintf('Relative Changes in Log Likelihood, Transition Matrix and Emission Matrix'));
        else
            disp(sprintf('Iteration %d relative changes:\nLog Likelihood: %f  Transition Matrix: %f  Emission Matrix: %f',...
                iteration, (abs(loglik-oldLL)./(1+abs(oldLL)))  ,norm(guessTR - oldGuessTR,inf)./numStates,norm(guessE - oldGuessE,inf)./numEmissions));
        end
    end
    % Durbin et al recommend loglik as the convergence criteria  -- we also
    % use change in TR and E. Use (undocumented) option trtol and
    % etol to set the convergence tolerance for these independently.
    %
    logliks(iteration) = loglik;
    if (abs(loglik-oldLL)./(1+abs(oldLL))) < tol
        if norm(guessTR - oldGuessTR,inf)./numStates < trtol
            if norm(guessE - oldGuessE,inf)./numEmissions < etol
                if verbose
                    disp(sprintf('Algorithm converged after %d iterations.',iteration))
                end
                converged = true;
                break
            end
        end
    end
    E =  pseudoE;
    TR = pseudoTR;
end
if ~converged
    warning('stats:hmmtrain:NoConvergence',...
        'Algorithm did not converge with tolerance %f in %d iterations.',tol,maxiter);
end
logliks(logliks ==0) = [];
