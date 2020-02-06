

function [hl_similarity,i_first_decision,i_first_element,i_second_decision,...
    i_second_element, gap_flags_go,estimated_gap_flags,...
    gt_object_flags,gt_config,estimated_config,...
    estimated_object_flags,estimated_interaction] =...
    hlp_classifiers_evaluation(best_start_keypoints,...
                    best_end_keypoints,best_start_config,...
                    best_estimated_config, best_estimated_arm_joints,...
                    original_segment_responses,original_gaps_resp,...
                    original_objects_resp,gap_flags_go,interaction_flag,...
                    gab_rectangles_bl,best_estimated_action_type,...
                    object_rect_cent_format, scene_objects,...
                    moved_object_names,key_config_data)

                
                
max_expected_plan_steps = 10; 
% estimated_rectangles = zeros(max_expected_plan_steps,4);
action_type=cell(max_expected_plan_steps,1);
cntr = 1;
pntr = 1;
while pntr <= size(best_end_keypoints,1) 
    %action is pushing
    if best_estimated_action_type(pntr) == 1
        action_type{cntr,:} = 'object';
        %estimated_rectangles(cntr,:) = best_end_keypoints(pntr,:);
        pntr = pntr+2;
    else
        %gap or reaching the traget
        action_type{cntr,:} = 'gap';
        %estimated_rectangles(cntr,:) = best_end_keypoints(pntr,:);
        pntr = pntr+1; 
    end
    cntr = cntr + 1 ;
end
%estimated_rectangles(cntr:end,:) =[];
action_type(cntr:end,:) =[];
             
%last action is always reach for the targetso ignore it 
%N_actions should be always 2 since we train using 2-rows data
N_actions = size(action_type,1)-1;
estimated_interaction = [ 0 0];
% selected_gaps = [];
% selected_objects = [];
for ii = 1 : N_actions
    my_action = action_type(ii);
    
    if strcmp(my_action,'gap')
        %selected_gaps = [selected_gaps;estimated_rectangles(ii,:)];
        estimated_interaction(ii) = 0;
    else
        %selected_objects = [selected_objects;estimated_rectangles(ii,:)];
        estimated_interaction(ii) = 1;
    end
end
                
%find the estimated gap flags
gab_rectangles_cent = to_rectangles_cent_format(gab_rectangles_bl);
% estimated_gap_flags = zeros(size(gab_rectangles_cent,1),1);
% for ii = 1 : size(selected_gaps,1)
%     dd = gab_rectangles_cent - selected_gaps(ii,:);
%     ss = sum(dd,2);
%     idx = ss==0;
%     estimated_gap_flags(idx)=1;
% end

%find the estimated object flags
% estimated_object_flags = zeros(size(object_rect_cent_format,1),1); 
% for ii = 1 : size(selected_objects,1)
%     dd = object_rect_cent_format - selected_objects(ii,:);
%     ss = sum(dd,2);
%     idx = ss==0;
%     estimated_object_flags(idx)=1;
% end

estimated_gap_flags = original_gaps_resp;
estimated_object_flags = original_objects_resp;

%adjusting gap_flags using information from interaction_flag
%for 2-rows 8-gaps structure
%gap_flags should be zero if interaction_flag is 1
if interaction_flag(1)==1
    gap_flags_go(1:4) = [0;0;0;0];
end
if interaction_flag(2)==1
    gap_flags_go(5:8) = [0;0;0;0];
end

%ground truth object flags
object_names = table2cell(scene_objects(2:end,1));
gt_object_flags = zeros(size(estimated_object_flags));
for ii = 1 : size(moved_object_names,1)
    idx = strcmp(object_names,moved_object_names(ii));
    gt_object_flags(idx)=1;
end

%human-like similarity metric
i_first_decision = interaction_flag(1) == estimated_interaction(1);
i_second_decision = interaction_flag(2) == estimated_interaction(2);

if estimated_interaction(1)==0
    dd = gap_flags_go(1:4) - estimated_gap_flags(1:4);
    
else
    dd = gt_object_flags(1:3) - estimated_object_flags(1:3);
end
i_first_element = ~any(dd);
i_first_all = i_first_decision * (i_first_decision + i_first_element);

if estimated_interaction(2)==0
    dd = gap_flags_go(5:8) - estimated_gap_flags(5:8);
else
    dd = gt_object_flags(4:6) - estimated_object_flags(4:6);
end
i_second_element = ~any(dd);
i_second_all = i_second_decision*(i_second_decision + i_second_element);

%metric
hl_similarity = 0.25*(i_first_all + i_second_all);

%arm configurations only if interactions are same 
if all(interaction_flag == estimated_interaction)
    gt_config = key_config_data(2:end,:);
    estimated_config = best_estimated_config;
else
    gt_config = [];
    estimated_config = [];
end

%segment classifier
% gap_objects_first_row = [gab_rectangles_cent(1:4,:);object_rect_cent_format(1:3,:)];
% gap_objects_second_row = [gab_rectangles_cent(5:8,:);object_rect_cent_format(4:6,:)];
% 
% %prepare groundtruth and estimated segment response matrix
% mat_size = [size(gap_objects_first_row,1) size(gap_objects_second_row,1)];
% all_gap_ids = find(gap_flags_go);
% all_obj_ids = find(gt_object_flags);
% gt_interaction_matrix = interaction_flag_matrix (interaction_flag,all_gap_ids,...
%     all_obj_ids,mat_size);
% 
% estim_gap_ids = find(estimated_gap_flags);
% estim_obj_ids = find(estimated_object_flags);
% estim_interaction_matrix = interaction_flag_matrix (estimated_interaction,estim_gap_ids,...
%     estim_obj_ids,mat_size);























 

end