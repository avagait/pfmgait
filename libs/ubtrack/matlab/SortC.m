function C = SortC(C)

% sort C(i).list by lenght(C(i).list)

ss = [];
for i = 1:length(C)
  ss = [ss length(C(i).list)];
end
[trash ixs] = sort(-ss);

C = C(ixs);
