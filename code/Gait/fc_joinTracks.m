function newTracks = fc_joinTracks(video_path, tracks, nBeans, metric, threshold)
    scores = tracks.scores;
    tracks = tracks.tracks;
    histograms = fc_calculateTracksHistograms(video_path, tracks, nBeans);
    newTracks = [];
    newScores = [];
    selected = zeros(length(tracks), 1);
    pos = 1;
    for i=1:length(histograms)
        if ~selected(i)
            newTrack = tracks(i).D(:,:);
            newScore = scores(i);
            for j=i+1:length(histograms)
                if ~selected(j)
                    d1 = pdist2(histograms{i}(1, :), histograms{j}(1, :), metric);
                    d2 = pdist2(histograms{i}(2, :), histograms{j}(2, :), metric);
                    d3 = pdist2(histograms{i}(3, :), histograms{j}(3, :), metric);
                    d = d1 + d2 + d3;

                    if d <= threshold
                        selected(i) = 1;
                        selected(j) = 1;
                        newTrack = cat(2, newTrack, tracks(j).D(:,:));
                        [val, idx] = sort(newTrack(1, :));
                        newTrack = newTrack(:, idx);
                        newScore = newScore + scores(j);
                    end
                end
            end
            
            newTracks(pos).D = newTrack;
            newScores(pos) = newScore;
            pos = pos + 1;
        end
    end
                   
    for j=1:length(newTracks)
        newTracks(j).D = InterpolateTrack(newTracks(j).D);
    end

    % Smooth tracks
    for trix = 1:length(newTracks)
        newTracks(trix).D(2:5,:) = me_smoothBB(newTracks(trix).D(1,:)-newTracks(trix).D(1,1),newTracks(trix).D(2:5,:),3,2);
    end

    newTracks = struct('tracks', newTracks, 'scores', newScores);
end
