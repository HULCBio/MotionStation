## Copyright (C) 2006 Michel D. Schmid <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{netOut}] = __trainlm (@var{net},@var{mInputN},@var{mOutput},@var{[]},@var{[]},@var{VV})
## A neural feed-forward network will be trained with @code{__trainlm}
##
## @example
## [netOut,tr,out,E] = __trainlm(net,mInputN,mOutput,[],[],VV);
## @end example
## @noindent
##
## left side arguments:
## @example
## netOut: the trained network of the net structure @code{MLPnet}
## tr :
## out:
## E  : Error
## @end example
## @noindent
##
## right side arguments:
## @example
## net    : the untrained network, created with @code{newff}
## mInputN: normalized input matrix
## mOutput: output matrix
## []     : unused parameter
## []     : unused parameter
## VV     : validize structure
## out:
## E  : Error
## @end example
## @noindent
##
##
## @noindent
## are equivalent.
## @end deftypefn

## @seealso{newff,prestd,trastd}

## Author: Michel D. Schmid

## Comments: see in "A neural network toolbox for Octave User's Guide" [4]
##  for variable naming... there have inputs or targets only one letter,
## e.g. for inputs is P written. To write a program, this is stupid, you can't
## search for 1 letter variable... that's why it is written here like Pp, or Tt
## instead only P or T.

function [net] = __trainlm(net,Im,Pp,Tt,VV)

  ## check range of input arguments
  error(nargchk(5,5,nargin))

  ## Initialize
  ##------------

  ## get parameters for training
  epochs   = net.trainParam.epochs;
  goal     = net.trainParam.goal;
  maxFail  = net.trainParam.max_fail;
  minGrad  = net.trainParam.min_grad;
  mu       = net.trainParam.mu;
  muInc    = net.trainParam.mu_inc;
  muDec    = net.trainParam.mu_dec;
  muMax    = net.trainParam.mu_max;
  show     = net.trainParam.show;
  time     = net.trainParam.time;

  ## parameter checking
  checkParameter(epochs,goal,maxFail,minGrad,mu,\
	               muInc,muDec,muMax,show,time);

  ## Constants
  shortStr = "TRAINLM";    # TODO: shortStr is longer as TRAINLM !!!!!!!!!!!
  doValidation = !isempty(VV);
  stop = "";


  #startTime = clock(); # TODO: maybe this row can be placed
                       # some rows later

  ## the weights are used in column vector format
  xx = __getx(net); # x is the variable with respect to, but no
                    # variables with only one letter!!
  ## define identity matrix
  muI = eye(length(xx));                  

  startTime = clock();  # if the next some tests are OK, I can delete
                        # startTime = clock(); 9 rows above..

  ## calc performance of the actual net
  [perf,vE,Aa,Nn] = __calcperf(net,xx,Im,Tt);
  if (doValidation)
    ## calc performance if validation is used
    VV.net = net; # save the actual net in the validate
    # structure... if no train loop will show better validate
    # performance, this will be the returned net
    vperf = __calcperf(net,xx,VV.Im,VV.Tt);
    VV.perf = vperf;
    VV.numFail = 0; # one of the stop criterias
  endif

  nLayers = net.numLayers;
  for iEpochs = 0:epochs # longest loop & one of the stop criterias
    ve = vE{nLayers,1};
    ## calc jacobian
    ## Jj is jacobian matrix
    [Jj] = __calcjacobian(net,Im,Nn,Aa,vE);

    ## rerange error vector for jacobi matrix
    ve = ve(:);

    Jjve = (Jj' * ve); # will be used to calculate the gradient

    normGradX = sqrt(Jjve'*Jjve);

    ## record training progress for later plotting
    ## if requested
    trainRec.perf(iEpochs+1) = perf;
    trainRec.mu(iEpochs+1) = mu;
    if (doValidation)
      trainRec.vperf(iEpochs+1) = VV.perf;
    endif

    ## stoping criteria
    [stop,currentTime] = stopifnecessary(stop,startTime,perf,goal,\
                           iEpochs,epochs,time,normGradX,minGrad,mu,muMax,\
                           doValidation,VV,maxFail);

    ## show train progress
    showtrainprogress(show,stop,iEpochs,epochs,time,currentTime, \
		  goal,perf,minGrad,normGradX,shortStr,net);

    ## show performance plot, if needed
    if !isnan(show) # if no performance plot is needed
      ## now make it possible to define after how much loops the
      ## performance plot should be updated
      if (mod(iEpochs,show)==0)
        plot(1:length(trainRec.perf),trainRec.perf);
	if (doValidation)
	  hold on;
	  plot(1:length(trainRec.vperf),trainRec.vperf,"--g");
	endif
      endif
    endif # if !(strcmp(show,"NaN"))
#    legend("Training","Validation");

    ## stop if one of the criterias is reached.
    if length(stop)
      if (doValidation)
        net = VV.net;
      endif
      break
    endif

    ## calculate DeltaX
    while (mu <= muMax)
      ## calculate change in x
      ## see [4], page 12-21
      dx = -((Jj' * Jj) + (muI*mu)) \ Jjve;

      ## add changes in x to actual x values (xx)
      x1 = xx + dx;
      ## now add x1 to a new network to see if performance will be better
      net1 = __setx(net,x1);
      ## calc now new performance with the new net
      [perf1,vE1,Aa1,N1] = __calcperf(net1,x1,Im,Tt);

      if (perf1 < perf)
        ## this means, net performance with new weight values is better...
        ## so save the new values
        xx = x1;
        net = net1;
        Nn = N1;
        Aa = Aa1;
        vE = vE1;
        perf = perf1;

        mu = mu * muDec;
        if (mu < 1e-20)   # 1e-20 is properly the hard coded parameter in MATLAB(TM)
          mu = 1e-20;
        endif
        break
      endif
      mu = mu * muInc;
    endwhile

    ## validate with DeltaX
    if (doValidation)
      vperf = __calcperf(net,xx,VV.Im,VV.Tt);
      if (vperf < VV.perf)
        VV.perf = vperf;
    	VV.net = net;
    	## if actual validation performance is better,
        ## set numFail to zero again
    	VV.numFail = 0;
      elseif (vperf > VV.perf)
        VV.numFail = VV.numFail + 1;
      endif
    endif

  endfor #for iEpochs = 0:epochs

#=======================================================
#
# additional functions
#
#=======================================================
  function checkParameter(epochs,goal,maxFail,minGrad,mu,\
	               muInc, muDec, muMax, show, time)
    ## Parameter Checking

    ## epochs must be a positive integer
    if ( !isposint(epochs) )
      error("Epochs is not a positive integer.")
    endif

    ## goal can be zero or a positive double
    if ( (goal<0) | !(isa(goal,"double")) )
      error("Goal is not zero or a positive real value.")
    endif

    ## maxFail must be also a positive integer
    if ( !isposint(maxFail) ) # this will be used, to see if validation can
      # break the training
      error("maxFail is not a positive integer.")
    endif

    if (!isa(minGrad,"double")) | (!isreal(minGrad)) | (!isscalar(minGrad)) | \
      (minGrad < 0)
      error("minGrad is not zero or a positive real value.")
    end

    ## mu must be a positive real value. this parameter is responsible
    ## for moving from stepest descent to quasi newton
    if ((!isa(mu,"double")) | (!isreal(mu)) | (any(size(mu)) != 1) | (mu <= 0))
      error("mu is not a positive real value.")
    endif

    ## muDec defines the decrement factor
    if ((!isa(muDec,"double")) | (!isreal(muDec)) | (any(size(muDec)) != 1) | \
  		 (muDec < 0) | (muDec > 1))
      error("muDec is not a real value between 0 and 1.")
    endif

    ## muInc defines the increment factor
    if (~isa(muInc,"double")) | (!isreal(muInc)) | (any(size(muInc)) != 1) | \
      (muInc < 1)
      error("muInc is not a real value greater than 1.")
    endif

    ## muMax is the upper boundary for the mu value
    if (!isa(muMax,"double")) | (!isreal(muMax)) | (any(size(muMax)) != 1) | \
      (muMax <= 0)
      error("muMax is not a positive real value.")
    endif

    ## check for actual mu value
    if (mu > muMax)
      error("mu is greater than muMax.")
    end

    ## check if show is activated
    if (!isnan(show))
	  if (!isposint(show))
        error(["Show is not " "NaN" " or a positive integer."])
      endif
    endif

    ## check at last the time argument, must be zero or a positive real value
    if (!isa(time,"double")) | (!isreal(time)) | (any(size(time)) != 1) | \
      (time < 0)
      error("Time is not zero or a positive real value.")
    end

  endfunction # parameter checking

#
# -----------------------------------------------------------------------------
#

  function showtrainprogress(show,stop,iEpochs,epochs,time,currentTime, \
          goal,perf,minGrad,normGradX,shortStr,net)

    ## check number of inputs
    error(nargchk(12,12,nargin));

    ## show progress
    if isfinite(show) & (!rem(iEpochs,show) | length(stop))
      fprintf(shortStr);   # outputs the training algorithm
      if isfinite(epochs)
        fprintf(", Epoch %g/%g",iEpochs, epochs);
      endif
      if isfinite(time)
        fprintf(", Time %4.1f%%",currentTime/time*100);   # \todo: Time wird nicht ausgegeben
      endif
      if isfinite(goal)
        fprintf(", %s %g/%g",upper(net.performFcn),perf,goal); # outputs the performance function
      endif
      if isfinite(minGrad)
        fprintf(", Gradient %g/%g",normGradX,minGrad);
      endif
      fprintf("\n")
      if length(stop)
        fprintf("%s, %s\n\n",shortStr,stop);
      endif
      fflush(stdout); # writes output to stdout as soon as output messages are available
    endif
  endfunction
  
#
# -----------------------------------------------------------------------------
#

  function [stop,currentTime] = stopifnecessary(stop,startTime,perf,goal,\
                        iEpochs,epochs,time,normGradX,minGrad,mu,muMax,\
						doValidation,VV,maxFail)

    ## check number of inputs
    error(nargchk(14,14,nargin));

    currentTime = etime(clock(),startTime);
    if (perf <= goal)
      stop = "Performance goal met.";
    elseif (iEpochs == epochs)
      stop = "Maximum epoch reached, performance goal was not met.";
    elseif (currentTime > time)
      stop = "Maximum time elapsed, performance goal was not met.";
    elseif (normGradX < minGrad)
      stop = "Minimum gradient reached, performance goal was not met.";
    elseif (mu > muMax)
      stop = "Maximum MU reached, performance goal was not met.";
    elseif (doValidation) 
	  if (VV.numFail > maxFail)
        stop = "Validation stop.";
      endif
    endif
  endfunction

# =====================================================================
#
# END additional functions
#
# =====================================================================

endfunction