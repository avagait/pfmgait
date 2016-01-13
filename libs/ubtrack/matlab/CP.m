function partitioning = CP(W)

% Clique-Partitioning of the complete
% weighted graph represented by the symmetric
% matrix W

% invoked with empty graph ?
if isempty(W)
  partitioning = [];
  return;
end

% Precondition: W must be square
nodes = size(W,1);
if not(nodes == size(W,2))
    disp('CP. Error: W must be square');
    return;
end

% Initialisation: partition <- singletons
for i = 1:1:nodes
    C(i).list = [i];
end
%disp(['Init partitioning: ']);
%PrintC(C);

for i=1:size(W,1)
	W(i,i)=-inf;
end

% Iterations
[W C needmore] = CP_Iterate(W, C);

while(needmore == 1)
   [W C needmore] = CP_Iterate(W, C);
end

% Output
partitioning = C;
%PrintC(C);
