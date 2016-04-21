function [coeff,latent,explained] = pcacov(v)
% PCACOV  Principal Components Analysis using a covariance matrix.
%   COEFF = PCACOV(V) performs principal components analysis on the P-by-P
%   covariance matrix V, and returns the principal component coefficients,
%   also known as loadings.  COEFF is a P-by-P matrix, with each column
%   containing coefficients for one principal component.  The columns are
%   in order of decreasing component variance.
%
%   PCACOV does not standardize V to have unit variances.
%
%   [COEFF, LATENT] = PCACOV(V) returns the principal component variances,
%   i.e., the eigenvalues of V.
%
%   [COEFF, LATENT, EXPLAINED] = PCACOV(V) returns the percentage of the
%   total variance explained by each principal component.
%
%   See also FACTORAN, PCARES, PRINCOMP.

%   References:
%     [1] Jackson, J.E., A User's Guide to Principal Components
%         Wiley, 1988.
%     [2] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, 1988.
%     [3] Seber, G.A.F., Multivariate Observations, Wiley, 1984.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.9.2.2 $  $Date: 2004/01/24 09:34:50 $

[u,latent,coeff] = svd(v);
latent = diag(latent);

totalvar = sum(latent);
explained = 100*latent/totalvar;
