function R = ContRuns(L)

% continuous runs in integer list L
%
% output:
% R{rix} = list of elements in run rix and indeces in L
% [M{rix} = missing run (always 1 less than R)]
%

% discontinuity points in L:
% the discont k is between L(k) and L(k+1)
discont = find(not(diff(L)==1));
discont = [0 discont length(L)];

R{length(discont)-1} = [];
for rix = 1:(length(discont)-1)
  runixs = (discont(rix)+1):(discont(rix+1));
  R{rix} = [L(runixs); runixs];
end

%M{length(R)-1} = [];
%for mix = 2:length(discont)-1
%  M{mix-1} = (L(discont(mix))+1):(L(discont(mix)+1)-1);
%end
