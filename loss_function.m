function [cell_count_diff,nbr_of_outliers, residuals] = loss_function(generated_indexes,validation_indexes, threshold)
validation_indexes_size = size(validation_indexes);
generated_indexes_size = size(generated_indexes);
cell_count_diff = validation_indexes_size(2) -generated_indexes_size(2);
nbr_of_outliers = 0;
outlier_index = [];
validation_inlier_pt = [];
generated_inlier_pt = [];
for i = 1:generated_indexes_size(2)
    
    length_to_val = vecnorm(validation_indexes - generated_indexes(:,i));
    
    inlier_index = find(length_to_val < threshold);
    
    if isempty(inlier_index)
        nbr_of_outliers = nbr_of_outliers +1;
        outlier_index = [outlier_index, i];
    else
        validation_inlier_pt = [validation_inlier_pt,validation_indexes(:,inlier_index(1))];
        generated_inlier_pt = [generated_inlier_pt, generated_indexes(:,i)];
        
    end
end

residuals = sum(vecnorm(validation_inlier_pt - generated_inlier_pt));

end

