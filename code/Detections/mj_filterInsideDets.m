function R = mj_filterInsideDets(R)
% R = mj_filterInsideDets(R)
% Remove detections that are inside others. Actually, we keep the one with
% highest score.
%
%  - R: can be either struct or D-style matrix
%
% (c) MJMJ/2014

if isstruct(R)
   
   nimgs = length(R);
   
   for ix = 1:nimgs,
      dets = R(ix).dets{1};
      if isempty(dets)
         continue
      end
      ndets = size(dets,1);
      
      for i = 1:ndets-1,
         if ~isfinite(dets(i,5)) % Already deleted
            continue
         end
         BB1 = minmax2wh(dets(i,1:4));
         for j = i+1:ndets,
            if ~isfinite(dets(j,5)) % Already deleted
               continue
            end
            BB2 = minmax2wh(dets(j,1:4));
            cmp = insideBB(BB1, BB2);
            
            if cmp > 0
               % Check greater score
               if dets(i,5) > dets(j,5)
                  dets(j,5) = -inf;
               else
                  dets(i,5) = -inf;
               end
               %          if cmp == 1
               %          elseif cmp == 2
               %          end % if
            end
            
         end % j
      end % i
      % Put back
      R(ix).dets{1} = dets(isfinite([dets(:,5)]), :);
   end % ix
else % D matrix
   allFrames = R(1,:);
   uFrames = unique(allFrames);
   nimgs = length(uFrames);
   
   for ix = 1:nimgs,
      fix = find(allFrames == uFrames(ix));
      keep = ones(size(fix));
      dets = [R(2:5, fix); R(7, fix)]';
      if length(dets) < 2, %isempty(dets)
         continue
      end
      ndets = size(dets,1);
      
      for i = 1:ndets-1,
         if ~isfinite(dets(i,5)) % Already deleted
            continue
         end
         BB1 = dets(i,1:4); %minmax2wh(dets(i,1:4));
         for j = i+1:ndets,
            if ~isfinite(dets(j,5)) % Already deleted
               continue
            end
            BB2 = dets(j,1:4); %minmax2wh(dets(j,1:4));
            cmp = insideBB(BB1, BB2);
            
            if cmp > 0
               scdif = dets(i,5) - dets(j,5);
               if abs(scdif) > 0.1*max([dets(i,5) , dets(j,5)])
                  % Check greater score
                  if dets(i,5) > dets(j,5)
                     dets(j,5) = -inf;
                  else
                     dets(i,5) = -inf;
                  end
               else
                  % Check greater area
                  if (dets(i,3)*dets(i,4)) > (dets(j,3)*dets(j,4))
                     dets(j,5) = -inf;
                  else
                     dets(i,5) = -inf;
                  end                     
               end % if
               %          if cmp == 1
               %          elseif cmp == 2
               %          end % if
            end
            
         end % j
      end % i
      % Put back
      keep = isfinite([dets(:,5)]);
      R(7,fix(~keep)) = -inf; %dets(isfinite([dets(:,5)]), :);
   end % ix
   
   % Delete bad ones
   R = R(:,isfinite(R(7,:)));
end
