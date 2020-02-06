
%train a classifier to select or reject path segmenmts 
%based on 2 rows structuring

function path_examples = train_path_classifier(gap_rectangles, gabs_flag_go,...
                        interaction_flag,pick_push_info,scene_objects_array,...
                        object_names, virtual_objects, start_pos, target_center,...
                        target_width,table_width,hand_width,scan_resolution)

                    
%gap rectangles in center-format                    
gap_cent_form = to_rectangles_cent_format(gap_rectangles);   

%exclude target from objects info
scene_objects_array(1,:)=[];
object_names(1,:)=[];
N_objects = size(scene_objects_array,1);

%in case of occlusion detection, remove the bottom wall of table (last entry)
%from virtual objects
virtual_objects(end,:)=[];
occluding_objects = [scene_objects_array;virtual_objects];

%which gaps were selected
all_gap_ids = find(gabs_flag_go);

%which objects were selected
moved_object_names = unique(pick_push_info(:,4));   
all_obj_ids = zeros(N_objects,1);
for ii=1:size(moved_object_names,1)
    all_obj_ids(strcmp(object_names , table2cell(moved_object_names(ii,1))))=1;
end
all_obj_ids = find(all_obj_ids);


gap_objects_first_row = [gap_cent_form(1:4,:);scene_objects_array(1:3,:)];
gap_objects_second_row = [gap_cent_form(5:8,:);scene_objects_array(4:6,:)];

%prepare groundtruth of paths
mat_size = [size(gap_objects_first_row,1) size(gap_objects_second_row,1)];
interaction_matrix = interaction_flag_matrix (interaction_flag,all_gap_ids,...
    all_obj_ids,mat_size);

%flag to show 0 if gap and 1 if object
gaps_objects_second_flag = [zeros(4,1) ; ones(3,1)];
gaps_objects_first_flag = [zeros(4,1) ; ones(3,1)];

path_examples = []; 

for ii = 1 : size(gap_objects_first_row,1)
    
    path_features =  path_description(gap_objects_first_row(ii,:),...
        gap_objects_second_row,occluding_objects, gaps_objects_second_flag,...
        start_pos, target_center,target_width,table_width,...
        gaps_objects_first_flag(ii),hand_width,scan_resolution);
    
    path_response = interaction_matrix(ii,:)';
    
    path_examples = [path_examples;path_features path_response];
    
end



end










