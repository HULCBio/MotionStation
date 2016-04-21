## Copyright (C) 2009 Esteban Cervetto <estebancster@gmail.com>
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{quotas}, @var{outcome} =} bfanalisis (@var{S}, @var{V}, @var{quota_ext}, @var{ultimate_ext})
## Calculate the extended Bornhuetter-Ferguson method for reserves in many ways. If all arguments are provided,
## it calculates 30 different estimations included in the @var{outcome} structure. It also returns the @var{quotas} used.
## 
##@var{outcome} had two levels:
##
##@group
##level 1: Type of Ultimate
## list of posible estimative methods:
##@example
##@multitable {xxxxxxxxxxxxx} {xxxxxxxxxxxxxxxxxx} {xxxxxxxxxxxxx} {xxxxxxxxxxxxxxxxx}
##@headitem FLAG @tab METHOD @tab REQUIRES @tab RELATED FUNCTION
##@item ultad       @tab Loss Ratio AD    @tab S,V          @tab  ultimatead.m       
##@item ultcc       @tab Cape Cod         @tab S,V          @tab  ultimatecc.m       
##@item ultexternal @tab none             @tab ultimate_ext @tab  none               
##@item ultld       @tab Loss Development @tab S            @tab  ultimateld.m       
##@item ultmack     @tab Mack             @tab S,V          @tab  ultimatemack.m     
##@item ultpanning  @tab Panning          @tab S            @tab  ultimatepanning.m  
##@end multitable
##@end example
##@end group
##@group
##level 2: Type of Quotas
## list of posible estimative methods:
##@example
##
##@multitable {xxxxxxxxxxxxxxxx} {xxxxxxxxxxxxxxxxxx} {xxxxxxxxxxxxx} {xxxxxxxxxxxxxxxxxx}
##@headitem FLAG @tab METHOD @tab REQUIRES @tab RELATED FUNCTION 
##@item quotasad         @tab  Loss Ratio AD    @tab S,V       @tab  quotaad.m          
##@item quotasexternal   @tab  none             @tab quota_ext @tab  none               
##@item quotasld         @tab  Loss Development @tab S         @tab  quotald.m          
##@item quotasmack       @tab  Mack             @tab S,V       @tab  quotamack.m        
##@item quotaspanning    @tab  Panning          @tab S         @tab  quotapanning.m
##@end multitable
##@end example
##@end group
##
## Parameters:
## @var{S} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## Optional:
## @var{v} is an mx1 vector of known volume measures (like premiums or the number of contracts).
## @var{quota_ext} is an 1xn vector with an external scheme of quotas.
## @group
## @example
## 
##                E[S(i,k+1)]
## quota(k) =   -------------,    k={0,1,n-1}
##                E[S(i,n) ]
##
## @end example
## @end group
## @var{ultimate_ext} is a mx1 vector wuth an external estimatios of the ultimate column.
##
##
## @seealso {bferguson}
## @end deftypefn
## @bye

## Author: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Maintainer: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Created: jul-2009
##
## Version: 1.1.0 
##
## Keywords: actuarial reserves insurance bornhuetter ferguson chainladder

function [quotas,outcome] = bfanalisis (S,V,quota_ext,ultimate_ext)

#check number of arguments in
if (nargin==0)
 usage("insuficient args. Enter a mxn triangle of losses at least");
else
 #check S 
 [m,n] = size (S);  #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
 u = m - n;                                        #rows of the upper square
 S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  
 quotas.ld = quotald(S);                           #quotas LD
 quotas.panning = quotapanning(S);                 #Panning quotas
 for k=1:n
  outcome.ultld.quotasld(:,k) = bferguson(S,quotas.ld,ultimateld(S,quotas.ld),k-1);
  outcome.ultld.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimateld(S,quotas.panning),k-1);
  outcome.ultpanning.quotasld(:,k) = bferguson(S,quotas.ld,ultimatepanning(S,quotas.ld),k-1);
  outcome.ultpanning.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimatepanning(S,quotas.panning),k-1);
 endfor
 
 if (nargin>1)
  # verify V
  if (size(V) ~= [m,1])
   usage(strcat("volume V must be of size [",num2str(m),",1]" ));
  else 
  for k=1:n	
  quotas.ad = quotaad(S,V);                                #quotas AD
  quotas.mack = quotamack(S,V);                            #quotas Mack  
  outcome.ultld.quotasad(:,k) = bferguson(S,quotas.ad,ultimateld(S,quotas.ad),k-1);
  outcome.ultld.quotasmack(:,k) = bferguson(S,quotas.mack,ultimateld(S,quotas.mack),k-1);
  outcome.ultpanning.quotasad(:,k) = bferguson(S,quotas.ad,ultimatepanning(S,quotas.ad),k-1);
  outcome.ultpanning.quotasmack(:,k) = bferguson(S,quotas.mack,ultimatepanning(S,quotas.mack),k-1);  
  outcome.ultad.quotasld(:,k) = bferguson(S,quotas.ld,ultimatead(S,V),k-1);
  outcome.ultad.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimatead(S,V),k-1);
  outcome.ultad.quotasad(:,k) = bferguson(S,quotas.ad,ultimatead(S,V),k-1);
  outcome.ultad.quotasmack(:,k) = bferguson(S,quotas.mack,ultimatead(S,V),k-1);
  outcome.ultcc.quotasld(:,k) = bferguson(S,quotas.ld,ultimatecc(S,V,quotas.ld),k-1);
  outcome.ultcc.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimatecc(S,V,quotas.panning),k-1);
  outcome.ultcc.quotasad(:,k) = bferguson(S,quotas.ad,ultimatecc(S,V,quotas.ad),k-1);
  outcome.ultcc.quotasmack(:,k) = bferguson(S,quotas.mack,ultimatecc(S,V,quotas.mack),k-1);
  outcome.ultmack.quotasld(:,k) = bferguson(S,quotas.ld,ultimatemack(S,V),k-1);
  outcome.ultmack.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimatemack(S,V),k-1);
  outcome.ultmack.quotasad(:,k) = bferguson(S,quotas.ad,ultimatemack(S,V),k-1);
  outcome.ultmack.quotasmack(:,k) = bferguson(S,quotas.mack,ultimatemack(S,V),k-1);  
  endfor
  if (nargin>2)
   #check out quota_ext
   if (size(quota_ext) ~= [1,n])
     usage(strcat("quota_ext must be of size [1,",num2str(n),"]" ));
   else
     for k=1:n	 
     quotas.external = quota_ext;                           #external quotas    	
     outcome.ultld.quotasexternal(:,k) = bferguson(S,quotas.external,ultimateld(S,quotas.external),k-1);   	
     outcome.ultpanning.quotasexternal(:,k) = bferguson(S,quotas.external,ultimatepanning(S,quotas.external),k-1);
     outcome.ultad.quotasexternal(:,k) = bferguson(S,quotas.external,ultimatead(S,V),k-1);
     outcome.ultcc.quotasexternal(:,k) = bferguson(S,quotas.external,ultimatecc(S,V,quotas.external),k-1);
     outcome.ultmack.quotasexternal(:,k) = bferguson(S,quotas.external,ultimatemack(S,V),k-1);
     endfor
     if (nargin>3)
      #verify ultimate_ext
      if (size(ultimate_ext) ~= [m,1])
       usage(strcat("ultimate_ext must be of size [",num2str(m),",1]" ));
      else 
        for k=1:n
        outcome.ultexternal.quotasld(:,k) = bferguson(S,quotas.ld,ultimate_ext,k-1);
        outcome.ultexternal.quotaspanning(:,k) = bferguson(S,quotas.panning,ultimate_ext,k-1);
        outcome.ultexternal.quotasad(:,k) = bferguson(S,quotas.ad,ultimate_ext,k-1);
        outcome.ultexternal.quotasmack(:,k) = bferguson(S,quotas.mack,ultimate_ext,k-1);
        outcome.ultexternal.quotasexternal(:,k) = bferguson(S,quotas.external,ultimate_ext,k-1);
        endfor
      end
    end   
   end	
  end
 end 
end

end
