
%compute the groundtruth interaction response matrix for training the
%segment classifier
function interaction_matrix = interaction_flag_matrix (interaction_flag,all_gap_ids,all_obj_ids, mat_size)

interaction_matrix = zeros(mat_size);

if sum(interaction_flag)== 0
     I = all_gap_ids(1);
     J = all_gap_ids(2)-4;
else
    if sum(interaction_flag)== 2
        I = all_obj_ids(1)+4;
        J = all_obj_ids(2)+1;
    else
        if interaction_flag(1)==0
            I = all_gap_ids(1);
            J = all_obj_ids(1)+1;
        else
            if length(all_gap_ids)>1
                I = all_gap_ids(2)-4;
            else
                I = all_gap_ids(1)-4;
            end
            J = all_obj_ids(1)+4;
        end
    end
end
interaction_matrix(I,J) = 1;

end


