classdef NM %< handle
% NM Data normalizer class
% ZCA is possible
%
%
% (c) MJMJ/2014


   
%% Define Properties
   properties
      M = [];  % Mean of data
      S = [];  % Std of data
      P = [];  % ZCA matrix
      cte = 0.001;  % For ZCA
   end
   
    properties (Access=private)
       data = [];   % Input data: each row is a sample
    end   
   
% %% Define Events
%    events
%       EmptyObject 
%    end

%% Define Methods   
   methods
      function nm = NM(samples)
         % samples: [nrows, ncols]
         
         
         % ZCA precomputation
         cte_ = 0.001;
         C = cov(samples);
         [V,D] = eig(C);
         P_ = V * diag(sqrt(1./(diag(D) + cte_))) * V'; % To avoid divide-by-zero
         
         % Mean
         M_ = mean(samples);
         samples = samples - repmat(M_, [size(samples,1),1]);
         
         % Std
         S_ = std(samples);
         samples = samples ./ repmat(S_+eps, [size(samples,1),1]);
         
         % Object
         nm.M = M_;
         nm.S = S_;
         nm.P = P_;
         nm.cte = cte_;
         nm.data = samples;
      end
      
      function enc = encode(obj, data)
      % Encodes data based on previously trained normalizer.
      % Output: normalized data
         if ~isempty(obj.M) && ~isempty(obj.S)
            data = data - repmat(obj.M, [size(data,1),1]);
            enc = data ./ repmat(obj.S+eps, [size(data,1),1]);
%          else         
%          % Trigger the EmptyObject event using notify         
%             notify(obj,'EmptyObject')   
         else
            enc = [];		 
         end
      end
      
      function enc = encodeZCA(obj, data)
      % Encodes data based on previously trained normalizer, using ZCA whitening
      % Output: normalized data
         if ~isempty(obj.M) && ~isempty(obj.P)
             enc = bsxfun(@minus, data, obj.M) * obj.P;
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

