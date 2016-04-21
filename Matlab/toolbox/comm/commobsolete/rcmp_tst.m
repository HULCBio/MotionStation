function [recover, msg, code] = rcmp_tst
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.10 $


N = 2;
 K = 1;
 numRows = 100;
 histGram = ones(8,1);

 msg = randint(1,K*numRows);
 rnd = 0.124*rand(2000,1);
 rside = rnd+0.5001;
 lside = 0.4999-rnd;
 gen = [744 554]
 [tranFunc cdParam] = oct2gen(gen);
 tranFunc
 cdParam
 code = encode(msg, N, K, 'convol', tranFunc);
 posIndex = find(code>0);
 negIndex = find(code<1);
 rBin = 1:floor(0.2*length(code));
 code(posIndex(rBin)) = rside(rBin);
 code(negIndex(rBin)) = lside(rBin);
 tranProb = [-inf 1/10 1/2 9/10;
       2/5 1/3 1/5 1/15;
       1/16 1/8 3/8 7/16];
 code=code.';
 recover = viterbi(code, tranFunc, 5*K*2, tranProb);