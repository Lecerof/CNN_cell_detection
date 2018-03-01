function [cell_count_diff,nbr_of_outliers, residuals] = loss_function(generated_indexes,validation_indexes, threshold)
% Loss function for evaluating the performance. Outputs the difference
% between the numbers of cells and the total amount generated by the
% network as primary loss. Secondary loss is number of outliers, i.e. the
% number of cells that are missclassified as cells and the third is the sum
% of the euclidian distance between the inliers and the validation indexes.

validation_indexes_size = size(validation_indexes);
generated_indexes_size = size(generated_indexes);
% difference between the number of cell elements and guessed cell elements
cell_count_diff = validation_indexes_size(2) - generated_indexes_size(2);

% initialize variables
nbr_of_outliers = 0;
outlier_index = [];
validation_inlier_pt = [];
generated_inlier_pt = [];

for i = 1:generated_indexes_size(2)
    
    length_to_val = vecnorm(validation_indexes - generated_indexes(:,i));
    % find the index in the validation containing an inlier
    inlier_index = find(length_to_val < threshold);
    % if there is none, it is an outlier
    if isempty(inlier_index)
        nbr_of_outliers = nbr_of_outliers +1;
        outlier_index = [outlier_index, i];
    else
        % save the inlier
        validation_inlier_pt = [validation_inlier_pt,validation_indexes(:,inlier_index(1))];
        generated_inlier_pt = [generated_inlier_pt, generated_indexes(:,i)];
        
    end
end
% Calculate the residual on all the inliers
residuals = sum(vecnorm(validation_inlier_pt - generated_inlier_pt));

end

