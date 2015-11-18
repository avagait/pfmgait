function vidEstClass = fc_estimateClasses(svmscores, TS, TF)
% finalSample = fc_computeRandomSubspace(sample)
% Compute a new sample using a random subspace.
%
% Input:
%  - svmscores: scores of the SVMs.
%  - TS: number of new bagging samples.
%  - TF: number of new random subspace samples.
%
% Output:
%  - vidEstClass: estimated classes.
%

if TS <= 1
    TS_ = 1;
else
    TS_ = TS;
end

if TF <= 1
    TF_ = 1;
else 
    TF_ = TF;
end

n = TS_ * TF_;
nclasses = size(svmscores, 1) / n;
vidEstClass = zeros(1, size(svmscores, 2));
votes = zeros(nclasses, 1);

scoresd = sign(svmscores);
for nsamp=1:size(scoresd, 2)
    index = 1;
    for i=1:n:size(scoresd, 1)
        votes(index) = sum(scoresd(i:i+n-1, nsamp) == 1);
        index = index + 1;
    end
    [~, vidEstClass(nsamp)] = max(votes);
end
