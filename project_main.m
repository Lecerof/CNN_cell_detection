
%% Load all images and their corresponding cell centers
load_images

%% generate validation set
generate_validation_data

%% generate training data
generate_traning_data
%% Set up option parameters for initial training
iterations_since_not_improving = 50; % one Epoch is 50 iterations
options = trainingOptions('sgdm', 'MaxEpoch',10, 'OutputFcn',       ...
                @(info)stopIfTrainingAccuracyNotImproving(info,     ...
                iterations_since_not_improving));
%% Initial training of network
random_indexes = randperm(length(training.image));
layers = cnn_classifier(patch_size);
net = trainNetwork(training.image(:,:,:,random_indexes),            ...
                   training.label(random_indexes), layers, options);
%% Setup parameters for training the network
iterations_since_not_improving = 30;
options = trainingOptions('sgdm', 'MaxEpoch',3, 'OutputFcn',       ...
                @(info)stopIfTrainingAccuracyNotImproving(info,     ...
                iterations_since_not_improving));

probability_to_train_on_hard = 0.7;


for i = 1:1000
    
    if (~isfield(training, 'hard') || rand < probability_to_train_on_hard)
        generate_traning_data
        random_indexes = randperm(length(training.image));
        training_data = training.image(:,:,:,random_indexes);
        training_labels = training.label(random_indexes);
        store_hard = 1;
    else
        random_indexes = randperm(length(training.hard.label));
        training_data = training.hard.image(:,:,:,random_indexes);
        training_labels = training.hard.label(random_indexes);
        store_hard = 0;
    end
    
    % Generate the new network
    net = trainNetwork(training_data, training_labels, net.Layers, options);
    % Store the examples that are missclassified
    if store_hard == 1
        if (~isfield(training, 'hard'))
            length_of_hard = 0;
            nbr_iter_bef_break = 3;
        else
            length_of_hard = training.hard.length;
        end

        generate_hard_training_data

        if length_of_hard < training.hard.length
            nbr_iter_bef_break = 3;
        else
            nbr_iter_bef_break = nbr_iter_bef_break - 1;
        end

        if nbr_iter_bef_break == 0
            break
        end
    end
end
% 
%%

stride = 1;
probmap = sliding_cnn(net, data.image{1}, stride);

img = data.image{1};
index_val = data.cellcenters{1};
imsize = size(img);
B = probmap(:,:,2);
%%
close all
% A = imresize(img, [size(probmap,1), size(probmap,2)], 'bilinear');

maxima = strict_local_maxima(B, 0.5, 1);
x_maxima = (maxima(1,:) - 1) * stride + 1;
y_maxima = (maxima(2,:) - 1) * stride + 1;
% -------------------------------------------------- %
% REFINING THE MAXIMA
refined_maxima = refine_maxima(maxima, B);
x_refmaxima = (refined_maxima(1,:) - 1) * stride + 1;
y_refmaxima = (refined_maxima(2,:) - 1) * stride + 1;
% -------------------------------------------------- %

imagesc(img);
hold on
scatter(x_maxima,y_maxima)
scatter(x_refmaxima,y_refmaxima)
scatter(index_val(1,:), index_val(2,:))
legend('Maxima', 'Refined Maxima', 'Validation indexes')
hold off
% figure
% imagesc(B)
%%
