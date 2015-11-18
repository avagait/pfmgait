classdef mj_PCA
% Dimensionality reduction with PCA
%
% (c) MJMJ/2013

%% Properties
 properties
   pcaP = [];  % Projection matrix
   pcaM = [];  % Mean matrix
 end
   
%% Methods   
 methods
   function pcaobj = mj_PCA(data, red_)
      % data: matrix where each row is a sample
      % red_: output dimensionality. If in (0,1), uses energy to decide dimensionality
      
      % Analyse possible problem with memory
      [nsamples, ndims] = size(data);
      GB = (ndims*ndims*8)/(10^9);
      if GB > 8      
         % Do economic PCA 
         [pcaP_, scores, ene] = princomp(data, 'econ');
      else
         % Do full PCA
         [pcaP_, scores, ene] = princomp(data);
      end
      clear scores
      if red_ > 1
         if red_ > length(ene)
            red_ = length(ene);
         end
         pcaobj.pcaP = pcaP_(:,1:red_);
      else
         ene2 = ene ./ sum(ene);
         cene = cumsum(ene2);
         di = find(cene > red_, 1, 'first');
         pcaobj.pcaP = pcaP_(:,1:di);
      end
      pcaobj.pcaM = mean(data,1);  % Mean of original data
   end
   
   function proj = encode(obj, data)
      % Reduce dimensionality of 'data'
      data = data - repmat(obj.pcaM, [size(data,1) 1]);
      proj = data * obj.pcaP; %obj.pcaP' * data;
   end
   
   function d = dims(obj)
      d = size(obj.pcaP,2);
   end
 end
   
end