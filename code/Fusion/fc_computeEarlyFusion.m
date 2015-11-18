function [histograms, labels, dictionary, lfiles, lvideos, pcaobjRGB, pcaobjDepth, pcaobjAudio] = fc_computeEarlyFusion(parameters, cams, trajectories, sequences, kinddic, encpars, sources, kindFusion)
    dictionary = [];
    if kindFusion == 2
        subjectsAux = encpars.subjects;
        encpars.subjects = parameters.subjects;
    end
    
    [histogramsRGB, histogramsDepth, histogramsAudio, labelsRGB, labelsDepth, labelsAudio, lfiles, lvideos, pcaobjRGB, pcaobjDepth, pcaobjAudio] = fc_loadEarlyFusionData(parameters, cams, trajectories, sequences, kinddic, encpars, sources);
    
    if kindFusion == 3 && sum(sources) == 1
        if sources(1)
            labelsA = labelsRGB;
            labelsB = labelsRGB;
            labelsC = labelsRGB;
        elseif sources(2)
            labelsA = labelsDepth;
            labelsB = labelsDepth;
            labelsC = labelsDepth;
        elseif sources(3)
            labelsA = labelsAudio;
            labelsB = labelsAudio;
            labelsC = labelsAudio;
        end
    end
    
    if ~isfield(parameters, 'pcaobjRGB')
        parameters.pcaobjRGB = pcaobjRGB;
        parameters.pcaobjDepth = pcaobjDepth;
        parameters.pcaobjAudio = pcaobjAudio;
    end
    
    if isequal(sources, [1 1 0])
        if length(labelsRGB) > length(labelsDepth)
            disp('WARN: different length');
            n = length(labelsRGB) / length(labelsDepth);
            labelsDepth = repmat(labelsDepth, n, 1);
            histogramsDepth = repmat(histogramsDepth, n, 1);
        end
        
        labelsA = labelsRGB;
        labelsB = labelsDepth;
        labelsC = labelsB;
    elseif isequal(sources, [1 0 1])
        if length(labelsRGB) > length(labelsAudio)
            disp('WARN: different length');
            n = length(labelsRGB) / length(labelsAudio);
            labelsAudio = repmat(labelsAudio, n, 1);
            histogramsAudio = repmat(histogramsAudio, n, 1);
        end
        
        labelsA = labelsRGB;
        labelsB = labelsAudio;
        labelsC = labelsB;
    elseif isequal(sources, [0 1 1])
        if length(labelsDepth) > length(labelsAudio)
            disp('WARN: different length');
            n = length(labelsDepth) / length(labelsAudio);
            labelsAudio = repmat(labelsAudio, n, 1);
            histogramsAudio = repmat(histogramsAudio, n, 1);
        end
        
        labelsA = labelsDepth;
        labelsB = labelsAudio;
        labelsC = labelsB;
    elseif isequal(sources, [1 1 1])
        if length(labelsRGB) > length(labelsAudio)
            disp('WARN: different length');
            n = length(labelsRGB) / length(labelsAudio);
            labelsAudio = repmat(labelsAudio, n, 1);
            histogramsAudio = repmat(histogramsAudio, n, 1);
        end
        
        if length(labelsDepth) > length(labelsAudio)
            disp('WARN: different length');
            n = length(labelsDepth) / length(labelsAudio);
            labelsAudio = repmat(labelsAudio, n, 1);
            histogramsAudio = repmat(histogramsAudio, n, 1);
        end
        
        labelsA = labelsRGB;
        labelsB = labelsDepth;
        labelsC = labelsAudio;
    end

    if isequal(labelsA, labelsB, labelsC)
        labels = labelsA;
        switch kindFusion
            case 1
                histograms = fc_concatenationEarlyFusion(histogramsRGB, histogramsDepth, histogramsAudio);
               
            case 2
                parameters.K = ceil(0.85*(size(histogramsRGB, 2) + size(histogramsAudio, 2)));
                if parameters.train
                    dictionary = fc_computeDictionaryFusion(histogramsRGB, histogramsAudio, parameters.K);
                else
                    dictionary = load(parameters.dictionaryFusion);
                    dictionary = dictionary.dictionaryFusion;
                end
                parameters.train = 0;
                encpars.subjects = subjectsAux;
                [histogramsRGB, histogramsDepth, histogramsAudio, labelsRGB, labelsDepth, labelsAudio, ~, ~] = fc_loadEarlyFusionData(parameters, cams, trajectories, sequences, kinddic, encpars, sources);
                if length(labelsRGB) > length(labelsAudio)
                    disp('WARN: different length');
                    n = length(labelsRGB) / length(labelsAudio);
                    labelsAudio = repmat(labelsAudio, n, 1);
                    histogramsAudio = repmat(histogramsAudio, n, 1);
                end
                if isequal(labelsRGB, labelsAudio)
                    labels = labelsRGB;
                    switch parameters.kindPooling
                        case 1
                            histograms = fc_computeAverageHistogram(histogramsRGB, histogramsAudio, dictionary, parameters.K);

                        case 2
                            histograms = fc_computeMaxHistogram(histogramsRGB, histogramsAudio, dictionary, parameters.K);

                        case 3
                            histograms = fc_computeHybridHistogram(histogramsRGB, histogramsAudio, dictionary, parameters.K);

                        otherwise
                            warning('Unexpected kind of pooling.')
                            histograms = [];
                            labels = [];
                    end
                else
                    disp('Error: different labels between results files.');
                    histograms = [];
                    labels = [];
                end
                
            case 3
                histograms = {histogramsRGB ; histogramsDepth ; histogramsAudio};
            otherwise
                warning('Unexpected kind of fusion.')
                histograms = [];
                labels = [];
        end
    else
        disp('Error: different labels between results files.');
        histograms = [];
        labels = [];
    end
end
