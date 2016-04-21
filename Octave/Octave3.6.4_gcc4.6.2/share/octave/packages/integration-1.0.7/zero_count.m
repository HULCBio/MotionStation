function num_fxpow=zero_count
%
%usage:  num_fxpow=zero_count
%
global NUM_COUNT

if ( exist('NUM_COUNT') == 1 )
  num_fxpow=NUM_COUNT;
endif

NUM_COUNT=0;

endfunction
