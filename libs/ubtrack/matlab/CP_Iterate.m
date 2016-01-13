function [OW, OC, needmore] = CP_Iterate(W, C)

% One iteration of Clique Partitioning
% Matrix OW, OC are the updated Weight and
% partitioning matrices
%
% This is already the version speeded up by Loic.
%

cliques_count = size(C,2);
% Termination condition
if cliques_count < 2
    OW = W;
    OC = C;
    needmore = 0;
    return;
end

% Best choices
[choices_scores choices] = max(W);


% Merging
changed = 0;      % are at least two cliques merged in this iteration ?
j = 1;            % index of latest inserted partition
to_keep   = [];   % list of rows/columns to keep in W
for i = 1:1:cliques_count
    choosen_clique = choices(i);
    
    % Merge cliques i and chosen_clique iff mutual
    % positive best choices
    if choices_scores(i) > 0 && i == choices(choosen_clique)
        if choosen_clique > i                                % prevent double-merging
            changed = 1;
	    new_clique = [C(i).list C(choosen_clique).list];
	    new_partition(j).list = new_clique;
            j = j + 1;
            W(:,i) = W(:,i) + W(:, choosen_clique);          % sums two columns of W (rows not done as the algo doesn't matter)
            W(i,:) = W(i,:) + W(choosen_clique,:);
            to_keep = [to_keep i];
        end
    else
        new_partition(j).list = C(i).list;                   % Leave clique alone
        j = j + 1;
        to_keep = [to_keep i];
    end
end

% reduce size of W
OC = new_partition;
OW = W(to_keep,to_keep);
needmore = (changed & size(new_partition,2) > 1);
