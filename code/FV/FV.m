classdef FV %< handle
% FV Fisher Vector class
% COMMENT ME!!!
%
% Requires: vlfeat-0.9.17 or greater
%
% (c) MJMJ/2013
%
% MOD: mjmarin, May 2014, doPCA can be a percentage in interval (0,1)
   
%% Define Properties
   properties
      means = [];  % Means of GMM
      covariances = []; % Covs of GMM
      priors = []; % Priors of GMM 
      data = [];   % Input data: each column is a sample
      K = 0;       % Number of Gaussians for GMM
      pcaP = [];   % Projection matrix, if PCA is used
      pcaM = [];   % Mean matrix, to be substracted before projection
   end
   
% %% Define Events
%    events
%       EmptyObject 
%    end

%% Define Methods   
   methods
      function fv = FV(data, K_, doPCA_)
         % doPCA_: if greater than 0, indicates the number of dimensions after PCA
         if nargin > 2 % Do PCA?
            if doPCA_ > 0
               if doPCA_ < 1
                  nd_ = size(data,1); % Number of features
                  doPCA_ = ceil(nd_ * doPCA_);
               end
               [pcaM_, scores] = princomp(data');
               % Keep the N first components
               fv.pcaP = pcaM_(:,1:doPCA_);
               fv.pcaM = mean(data,2);  % Mean of original data
               data = scores(:,1:doPCA_)';               
            end
         end 
         [meansG, covariancesG, priorsG] = vl_gmm(data, K_, ...
           'MaxNumIterations', 1000, ...
           'NumRepetitions', 3, ...
           'Verbose', 'CovarianceBound', 10e-06) ;
        fv.means = meansG;
        fv.covariances = covariancesG;
        fv.priors = priorsG;
        fv.K = K_;
      end
      
      function enc = encode(obj, data)
      % Encodes data based on previously trained dictionary (learnt during construction of the object).
      % Output: the Fisher Vectors
         if ~isempty(obj.means)
            if ~isempty(obj.pcaP)               
               data = data - repmat(obj.pcaM, [1 size(data,2)]);
               data = obj.pcaP' * data;
            end
            enc = vl_fisher(data, obj.means, obj.covariances, obj.priors, 'normalized', 'squareroot');
%          else         
%          % Trigger the EmptyObject event using notify         
%             notify(obj,'EmptyObject')   
         else
            enc = [];		 
         end
      end
      
      function obj = clearData(obj)
         % Delete data to save memory
         obj.data = [];
      end
   end
   
end

