function [histogramsRGB, histogramsDepth, histogramsAudio, labelsRGB, labelsDepth, labelsAudio, lfiles, lvideos, pcaobjRGB, pcaobjDepth, pcaobjAudio] = fc_loadEarlyFusionData(parameters, cams, trajectories, sequences, kinddic, encpars, sources)
    % Video
    if sources(1)
        encpars.dbname = parameters.RGB.dbname;
        encpars.doPCA = parameters.RGB.doPCA;
        if mj_isGaitPyramid(parameters.RGB.partitions_train)
            [histogramsRGB, labelsRGB, lfiles, lvideos] = mj_calculateHistogramsPyrGen(parameters.RGB.featuresPath, parameters.RGB.tracksPath, ...
                parameters.RGB.partitions_train, parameters.RGB.dictionary, cams, trajectories, sequences, kinddic, encpars);
        else
            [histogramsRGB, labelsRGB, lfiles, lvideos] = mj_calculateHistogramsGen(parameters.RGB.featuresPath, parameters.RGB.tracksPath, ...
                parameters.RGB.partitions_train, parameters.RGB.dictionary, cams, trajectories, sequences, kinddic, encpars);
        end
        
        % Do PCAH RGB
        if parameters.doPCAHRGB > 0
            if parameters.train
                pcaobjRGB = mj_PCA(histogramsRGB, parameters.doPCAHRGB);
            else
                pcaobjRGB = parameters.pcaobjRGB;
            end
            histogramsRGB = pcaobjRGB.encode(histogramsRGB);
        end
    else
        histogramsRGB = [];
        labelsRGB = [];
        pcaobjRGB = [];
    end

    % Depth
    if sources(2)
        encpars.dbname = parameters.Depth.dbname;
        encpars.doPCA = parameters.Depth.doPCA;
        if mj_isGaitPyramid(parameters.Depth.partitions_train)
            [histogramsDepth, labelsDepth, lfiles, lvideos] = mj_calculateHistogramsPyrGen(parameters.Depth.featuresPath, parameters.Depth.tracksPath, ...
                parameters.Depth.partitions_train, parameters.Depth.dictionary, cams, trajectories, sequences, kinddic, encpars);
        else
            [histogramsDepth, labelsDepth, lfiles, lvideos] = mj_calculateHistogramsGen(parameters.Depth.featuresPath, parameters.Depth.tracksPath, ...
                parameters.Depth.partitions_train, parameters.Depth.dictionary, cams, trajectories, sequences, kinddic, encpars);
        end
        
        % Do PCAH RGB
        if parameters.doPCAHDepth > 0
            if parameters.train
                pcaobjDepth = mj_PCA(histogramsDepth, parameters.doPCAHDepth);
            else
                pcaobjDepth = parameters.pcaobjDepth;
            end
            histogramsDepth = pcaobjDepth.encode(histogramsDepth);
        end
    else
        histogramsDepth = [];
        labelsDepth = [];
        pcaobjDepth = [];
    end

    % Audio
    if sources(3)
        encpars.doPCA = parameters.Audio.doPCA;
        encpars.dbname = parameters.Audio.dbname;
        encpars.kinddata = 'audio';
        [histogramsAudio, labelsAudio, lfiles, lvideos] = mj_calculateHistogramsGen(parameters.Audio.featuresPath, parameters.Audio.tracksPath, ...
            parameters.Audio.partitions_train, parameters.Audio.dictionary, cams, trajectories, sequences, kinddic, encpars);
        
        % Do PCAH Audio
        if parameters.doPCAHAudio > 0
            if parameters.train
                pcaobjAudio = mj_PCA(histogramsAudio, parameters.doPCAHAudio);
            else
                pcaobjAudio = parameters.pcaobjAudio;
            end
            histogramsAudio = pcaobjAudio.encode(histogramsAudio);
        end
    else
        histogramsAudio = [];
        labelsAudio = [];
        pcaobjAudio = [];
    end
end
