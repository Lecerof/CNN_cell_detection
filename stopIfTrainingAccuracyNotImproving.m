function stop = stopIfTrainingAccuracyNotImproving(info,N)

stop = false;

% Keep track of the best training accuracy and the number of trainings for which
% there has not been an improvement of the accuracy.
persistent bestTrainAccuracy
persistent valLag

% Clear the variables when training starts.
if info.State == "start"
    bestTrainAccuracy = 0;
    valLag = 0;
    
elseif info.TrainingAccuracy > 0.9
    
    % Compare the current training accuracy to the best accuracy so far,
    % and either set the best accuracy to the current accuracy, or increase
    % the number of validations for which there has not been an improvement.
    if info.TrainingAccuracy > bestTrainAccuracy
        valLag = 0;
        bestTrainAccuracy = info.TrainingAccuracy;
    else
        valLag = valLag + 1;
    end
    
    % If the validation lag is at least N, that is, the training accuracy
    % has not improved for at least N validations, then return true and
    % stop training.
    if valLag >= N
        stop = true;
    end
    
end

end