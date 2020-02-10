
% to increase the samples of data_in to become of the required_size
% by repeating random saples from data_in

function [pos_balanced_class, neg_balanced_class] = adjust_class_size(pos_class_data,neg_class_data,adjust_type)


pos_size = size(pos_class_data,1);
neg_size = size(neg_class_data,1);


if pos_size==neg_size
    %check if no balance is required
    pos_balanced_class = pos_class_data;
    neg_balanced_class = neg_class_data;
else
    
    if pos_size > neg_size
        %if the positive class has larger number of samples
        large_class = pos_class_data;
        large_size = pos_size;
        small_class = neg_class_data;
        small_size  = neg_size;
        large_lbl = 1;
    else
        %if the negative class has larger number of samples
        large_class = neg_class_data;
        large_size = neg_size;
        small_class = pos_class_data;
        small_size  = pos_size;
        large_lbl = 0;
    end
    
    %if it is required to increase the smaller class
    if strcmp(adjust_type , 'INC')
        diff_multip = floor(large_size/small_size);
        remain = rem(large_size , small_size);
        repeated_data = repmat(small_class,diff_multip,1);
        added_data = small_class(randsample(1:small_size,remain) , :);
        balanced_small = [repeated_data;added_data];
        if large_lbl == 1
            neg_balanced_class = balanced_small;
            pos_balanced_class = pos_class_data;
        else
            pos_balanced_class = balanced_small;
            neg_balanced_class = neg_class_data;
        end
    
    %if it is required to decrease the larger class    
    elseif strcmp(adjust_type , 'DEC')
%         diff_size = large_size - small_size; 
        balanced_large = large_class(randsample(1:large_size,small_size) , :);
        if large_lbl == 1
            pos_balanced_class = balanced_large;
            neg_balanced_class = neg_class_data;
        else
            pos_balanced_class = pos_class_data;
            neg_balanced_class = balanced_large;
        end
    end
    
    
end





