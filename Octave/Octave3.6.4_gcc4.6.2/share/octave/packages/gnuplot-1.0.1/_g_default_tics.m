## ticpos = _g_default_tics (minmax, ntics = 5) - Set tics in interval for plotting
##
## Tics to place in interval minmax, approximately ntics of them (default 5),
## while ensuring the spacing between tics is 1eL, 2eL or 5eL, for some integer
## L.
function t = _g_default_tics (rng, ntics)

if nargin < 2, ntics = 5; endif

step = diff(rng)/ntics;
if !step, step = 1; endif
lstep = 10 ^ floor (log10 (step));

## Pick tic w/ leading 1,2 or 5
step = lstep * [1 2 2 5 5 5 5 10 10 10](round (step/lstep));


t = step*[ceil(rng(1)/step):floor(rng(2)/step)];
