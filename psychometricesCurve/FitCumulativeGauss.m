function [mu, sigma, lapserate, stdMuSig] = FitCumulativeGauss(X,L)

% -------------------------------------------------------------------------
%   [mu, sigma, lapserate, stdMuSig] = FitCumulativeGauss(X,L)
%
%   This functions fits a Cumulative Gauss to the input X using glmfit
%
%   Input parameters:
%   X = the results from a psychophysical experiment and should be a three-
%       column matrix with the following format:
%       [ stimulus, number percieved as comparison > standard , number of
%       trials ]
%   L = assumed lapserate (e.g. from fit across pooled results for a
%       participant).
%       [optional: Default is zero or fitted value (see below)].
%
%   Output parameters:
%   mu = the mean or centre of the underlying Gaussian distribution. In
%       terms of psychophysical experiments this will be regarded as the
%       PSE (Point of Subjective Equality).
%   sigma = is the standard deviation of the Gaussian distribution
%       underlying the curve. In many cases this is also taken as the JND
%       (Just Noticable Difference) for psychophysical experiments.
%   lapserate = the lapserate. If a L is provided as input lapserate will
%       be the same value as L. Otherwise a lapserate will be included as a
%       free parameter in the fitting procedure.
%   stdMuSig = the standard deviation in the fitted values of mu and sigma.
%
%   Note, if the lapserate is not requested as an outputparameter it will
%   also not be fitted. That is, a lapserate of zero will be assumed.
%
%   Note also that the lapserate entered here will affect both sides of the
%   psychometric curve equally. This is because we assume that we here only
%   consider psychometric curves for which the curve goes from 0 to 1 and 
%   lapses due to inattention to the stimulus should not be dependent on
%   the actual conditions shown.
%
%   by Loes van Dam, 2014
%   Loes.van_Dam@uni-bielefeld.de
%   
% -------------------------------------------------------------------------

warning('');

if nargout < 3 && (nargin < 2 || isempty(L)),
    % ---------------------------------------------------------------------
    %   either only mu or mu and sigma requested
    %
    %   We assume the lapserate to be zero. Note though, that this does not
    %   always provide the best fit (humans are not machines, except maybe
    %   for participant LD ;-) )
    % ---------------------------------------------------------------------

    [b,dev,stats] = glmfit(X(:,1),X(:,2:3),'binomial','link','probit');

    mu = -b(1)/b(2);
    sigma = 1/b(2);
    lapserate = 0;
            
else
    % ---------------------------------------------------------------------
    %   Take lapserate into account
    % ---------------------------------------------------------------------
    

    if nargin < 2 || isempty(L),
        % -----------------------------------------------------------------
        %   Treat lapserate as a free parameter
        % -----------------------------------------------------------------
        fprintf(['Now fitting a lapserate to the data.\n'...
            'Warning: This part of the toolbox has not been optimized yet, ',...
            'so if in doubt compare fit and results.\n'])

        Lstart = 0:0.01:0.05;
        lapserate = 0;
        DevEst = 10000000;
        
        for L0 = Lstart,
            [Lbest, DevBest] = fminsearch(@Ldeviance,L0);
            
            if DevBest < DevEst,
                lapserate = Lbest;
            end
        end

        L = lapserate;
        linkfunction = @(p) linkfunctionDef(p,L);
        linkderivative = @(p) linkderivativeDef(p,L);
        linkinverse = @(x) (1-2*L)*normcdf(x,0,1)+L;

        linkfunctionList = {linkfunction, linkderivative, linkinverse};
        [b,dev,stats] = glmfit(X(:,1),X(:,2:3),'binomial','link',linkfunctionList);

        mu = -b(1)/b(2);
        sigma = 1/b(2);
            
    else
        % -----------------------------------------------------------------
        %   Treat lapserate as a fixed parameter as specified by L
        % -----------------------------------------------------------------
        linkfunction = @(p) linkfunctionDef(p,L);
        linkderivative = @(p) linkderivativeDef(p,L);
        linkinverse = @(x) (1-2*L)*normcdf(x,0,1)+L;

        linkfunctionList = {linkfunction, linkderivative, linkinverse};

        [b,dev,stats] = glmfit(X(:,1),X(:,2:3),'binomial','link',linkfunctionList);

        mu = -b(1)/b(2);
        sigma = 1/b(2);
        lapserate = L;
        
    end
    
end
% -------------------------------------------------------------------------
%   Compute error estimates for mu and sigma
%   These can be used to compute Confidence Intervals if necessary if a
%   Gaussian distribution on the parameters is assumed
%
%   The error estimates are variances computed from the stats for b(1) and
%   b(2) using the Delta Method (see for instance Moscatelli, Mezzetti &
%   Lacquaniti (2012) Journal of Vision,12(11):26, 1?17)
%
%   variance(pse) = (1/b2^2)(var(b1)+ pse^2*var(b2) + 2*pse*cov(b1,b2))
%   variance(jnd) = (-1/b2^2)^2 * variance(b2)
%
%   Alternatively a boostrap method can be used to compute the error
%   estimates (see Wichmann and Hill (2001), Perception & Psychophysics,
%   63(8), 1314-1329). This alternative method is however work in progress
%   and not part of this package yet.
% -------------------------------------------------------------------------

if strcmp(lastwarn, 'Iteration limit reached.'),
    fprintf(['Warning: The sampling resolution may have been to sparse. Does your data look like a step-function?\n',...
        'If so redesign your experiment to include a higher resolution in your sampling.\n'])
    stdMuSig = NaN*[1,1];
else
    stdMuSig = [(1/b(2))*sqrt(stats.covb(1,1)+ mu^2*stats.covb(2,2) + 2*mu*stats.covb(1,2)), ...
                (1/b(2)^2) * stats.se(2)];
end


% ----------------- subfunctions ------------------------------------------

function [x] = linkfunctionDef(p,Lr) 
    p = min(max(p,Lr),1-Lr);
    x = norminv((p-Lr)/(1-2*Lr),0,1);
end
function [x] = linkderivativeDef(p,Lr)
    p = min(max(p,Lr),1-Lr);
    x = sqrt(2*pi)*exp(erfinv( (2*(p-Lr)./(1-2*Lr))-1 ).^2)./(1-2*Lr);
end

function [dev] = Ldeviance(Lr)
    if Lr < 0 || Lr > 0.05,
        dev = 10000000;
    else
        linkfunction = @(p) linkfunctionDef(p,Lr);
        linkderivative = @(p) linkderivativeDef(p,Lr);
        linkinverse = @(x) (1-2*Lr)*normcdf(x,0,1)+Lr;
        
        linkfunctionList = {linkfunction, linkderivative, linkinverse};
        [b,dev] = glmfit(X(:,1),X(:,2)./X(:,3),'binomial','link',linkfunctionList);
        
        if sum(isnan(b))>0,
            dev = 10000000;
        end
    end
end

end