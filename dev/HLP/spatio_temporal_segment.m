

function [ object_inetaction_data , keypoints_sorted] = spatio_temporal_segment...
                              (trial_path,trial_name, pick_push_info)
         

%Psition change threshold 
shared_params = experiments_shared_params();
pos_change_tol = shared_params.pos_change_tol;
                          
%find which objects that were pushed or picked in the interaction
[object_in_interaction, idx ]= unique(table2cell(pick_push_info(:,4)));
object_pick_push_type = table2cell(pick_push_info(idx,5));

num_objects = size(object_in_interaction,1);

%initialize structure of objects info
object_inetaction_data(num_objects).name = [];

%initialize keypoints array of times of interaction
keypoints_array = zeros(num_objects,2);
cntr = 1;

%iterate on each object to find the interaction times and positions
for ii= 1 : num_objects
    %read the interaction file
    object_name = object_in_interaction(ii);
    object_movement = readtable(fullfile(trial_path,['movement/' char(object_name) '_movement_' trial_name '.csv']));
    %x position
    object_x_pos = table2array(object_movement(:,2));
    %changes in position
    pos_changes = diff(object_x_pos);
    %ensure that the change in position is large enough (more than the threshold of position_tolerance)
    pos_change_ids = find(abs(pos_changes)>pos_change_tol);
    
    %if there is considerable movement of the object
    if ~isempty(pos_change_ids)   
        %recorde name, position and time info
        object_change_period = [pos_change_ids(1)-1  pos_change_ids(end)+1 ];
        object_change_pos =  table2array(object_movement(object_change_period(1):object_change_period(end),[2 4]));
        %object_data
        object_inetaction_data(cntr).name = object_name;
        object_inetaction_data(cntr).pos = object_change_pos;
        object_inetaction_data(cntr).period = object_change_period;
        object_inetaction_data(cntr).pick_push = object_pick_push_type(ii);
        keypoints_array(cntr,:)=object_change_period;
        cntr = cntr + 1 ;
    end
end

%Delete any excessive objects in the object_inetaction_data structure
object_inetaction_data(cntr:end)=[];
keypoints_array(cntr:end,:)=[];

%force sorting the time-key-points and respective motion
[~ , id_sort ]= sort(keypoints_array(:,1));
keypoints_sorted = keypoints_array(id_sort,:);



end