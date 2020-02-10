
% to increase the samples of data_in to become of the required_size
% by repeating random saples from data_in

function data_out = increase_group_samples(data_in,required_size)

data_in_size = size(data_in,1);
% diff_size = required_size - size(data_in,1);

diff_multip = floor(required_size/data_in_size);

remain = rem(required_size , data_in_size);

repeated_data = repmat(data_in,diff_multip,1);

added_data = data_in(randsample(1:data_in_size,remain) , :);

data_out = [repeated_data;added_data];


