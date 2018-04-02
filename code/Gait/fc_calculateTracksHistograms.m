function histograms = fc_calculateTracksHistograms(data_path, tracks, nBeans)
    kindData = isdir(data_path);
    if kindData == 0 % Video
	[pathstr, name, ext] = fileparts(data_path);
	parts = regexp(name, '_', 'split');
	if length(parts) > 1
	    flip = 1;
	    data_path = strcat(pathstr, '/', parts{1}, ext);
	else 
	    flip = 0;
	end
        vidObj = VideoReader(data_path);
        vidHeight = vidObj.Height;
        vidWidth = vidObj.Width;
        M = [];
	k = 1;
	while hasFrame(vidObj)
    	    fr = readFrame(vidObj);
            M(:, :, :, k) = fr;
    	    k = k + 1;
	end
    end

    histograms = cell(length(tracks), 1);
    for i=1:length(tracks)
        histograms{i} = zeros(3, nBeans);
        tracks(i).D(2, tracks(i).D(2, :) < 1) = 1;
        tracks(i).D(3, tracks(i).D(3, :) < 1) = 1;
        for j=1:size(tracks(i).D, 2)
            if kindData == 1 % Images
                path = strcat(data_path, sprintf('%06d.png', tracks(i).D(1, j)));
                img = imread(path);
                x2 = round(tracks(i).D(2, j) + tracks(i).D(4, j));
                if x2 > size(img, 1)
                    x2 = size(img, 1);
                end
                y2 = round(tracks(i).D(3, j) + tracks(i).D(5, j));
                if y2 > size(img, 2)
                    y2 = size(img, 2) / 2;
                end
                img = img(round(tracks(i).D(2, j)):x2, round(tracks(i).D(3, j)):y2, :);
            else % Video
                l = tracks(i).D(1, j);
		if l > size(M, 4)
		    img = zeros(size(M, 1), size(M, 2), size(M, 3));
		else
		    img = M(:,:,:,l);
		end
                
		if flip
		    img = flipdim(img, 2);
		end
                x2 = round(tracks(i).D(2, j) + tracks(i).D(4, j));
                if x2 > size(img, 2)
                    x2 = size(img, 2);
                end
                y2 = round(tracks(i).D(3, j) + tracks(i).D(5, j));
                if y2 > size(img, 1)
                    y2 = size(img, 1) / 2;
                end
                img = img(round(tracks(i).D(3, j)):y2, round(tracks(i).D(2, j)):x2, :);
            end

            histogram = zeros(3, nBeans);
            histogram(1, :) = imhist(img(:, :, 1), nBeans);
            histogram(2, :) = imhist(img(:, :, 2), nBeans);
            histogram(3, :) = imhist(img(:, :, 3), nBeans);
            histograms{i} = histograms{i} + histogram;
        end
        histograms{i} = histograms{i} / sum(histograms{i}(1, :));
    end
end
