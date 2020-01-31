%animate_trajectory_objects
%core function to animate the trajectory and the pushing/picking of objects

function animate_trajectory_objects(trial_path,trial_name, pick_push_info,...
    trajectory_timestamp,hand_trajectory_xy,elbow_trajectory_xy,...
    shoulder_trajectory_xy,neck_trajectory_xy,scene_objects,...
    object_rectangle_handles,plot_scale,writerObj)

%a threshold on distance to be considered as a movement
pos_change_tol = 0.001;

%find which objects that were pushed or picked in the interaction
object_in_interaction = unique(table2cell(pick_push_info(:,4)));

num_objects = size(object_in_interaction,1);

%initialize structure
object_inetaction_data(num_objects).name = [];

%initialize keypoints array
keypoints_array = zeros(num_objects,2);

cntr = 1;

%iterate on each to find the interaction times and positions
for ii= 1 : num_objects
    object_name = object_in_interaction(ii);
    
    %read the interaction file
    object_movement = readtable(fullfile(trial_path,...
        ['movement/' char(object_name) '_movement_' trial_name '.csv']));
    
    %x position
    object_x_pos = table2array(object_movement(:,2));
    
    %changes in position
    pos_changes = diff(object_x_pos);
    
    %ensure that the change in position is large enough 
    %(more than the threshold of position_tolerance)
    pos_change_ids = find(abs(pos_changes) > pos_change_tol);
    
    %confirm continuity of time of location change
    %assert(all(diff(pos_change_ids))==1)

    %if there is considerable movement of the object
    if ~isempty(pos_change_ids)   
        %recorde name, position and time info
        object_change_period = [pos_change_ids(1)-1  pos_change_ids(end)+1 ];
        object_change_pos = table2array(object_movement(...
            object_change_period(1):object_change_period(end),[2 4]));
        
        %object_data
        object_inetaction_data(cntr).name = object_name;
        object_inetaction_data(cntr).pos = object_change_pos;
        object_inetaction_data(cntr).period = object_change_period;
        keypoints_array(cntr,:)=object_change_period;
        
        %update
        cntr = cntr + 1 ;
    end
end


%Delete any excessive objects in the object_inetaction_data structure
object_inetaction_data(cntr:end)=[];
keypoints_array(cntr:end,:)=[];


%force sorting the key points and respective motion
[~ , id_sort ]= sort(keypoints_array(:,1));
keypoints_sorted = keypoints_array(id_sort,:);


% %Delete the case with no considerable motion
% if keypoints_sorted(1,1)==0
%     keypoints_sorted(1,:)=[];
% end

%object ids used to create rectangles on figure
object_ids = table2cell(scene_objects(:,1));

%Trajectory segment
segment_start_id = 1;
segment_end_id = keypoints_sorted(1)-1;

%Plot arm trajectory
%line(hand_trajectory_xy(segment_start_id:segment_end_id,1),...
%hand_trajectory_xy(segment_start_id:segment_end_id,2))
plot_arm_trajectory(hand_trajectory_xy(segment_start_id:segment_end_id,:),... 
elbow_trajectory_xy(segment_start_id:segment_end_id,:),...
shoulder_trajectory_xy(segment_start_id:segment_end_id,:),...
neck_trajectory_xy(segment_start_id:segment_end_id,:),...
trajectory_timestamp(segment_start_id:segment_end_id,:),writerObj);


for ii= 1 : size(keypoints_sorted,1)
   
    %start and end of this segment
    segment_start_id = keypoints_sorted(ii , 1);
    segment_end_id = keypoints_sorted(ii, 2);
    
    object_change_pos = plot_scale*object_inetaction_data(id_sort(ii)).pos;
    object_name = object_inetaction_data(id_sort(ii)).name;
    object_id = find(strcmp( object_name , object_ids));
    
    plot_arm_and_objects(hand_trajectory_xy(segment_start_id:segment_end_id,:), ...
        elbow_trajectory_xy(segment_start_id:segment_end_id,:),...
        shoulder_trajectory_xy(segment_start_id:segment_end_id,:),  ...
        neck_trajectory_xy(segment_start_id:segment_end_id,:),  ...
        object_change_pos,object_rectangle_handles,...
    object_id,trajectory_timestamp(segment_start_id:segment_end_id,:),writerObj)
    
    %animate the intermediate motion between segments
    if ii<size(keypoints_sorted,1)
        next_start = keypoints_sorted(ii+1,1);
        if segment_end_id < next_start-1
            %line(hand_trajectory_xy(segment_end_id:next_start-1,1),...
            %hand_trajectory_xy(segment_end_id:next_start-1,2))
            plot_arm_trajectory(hand_trajectory_xy(segment_end_id:next_start-1,:),...
                elbow_trajectory_xy(segment_end_id:next_start-1,:),...
                shoulder_trajectory_xy(segment_end_id:next_start-1,:),neck_trajectory_xy(segment_end_id:next_start-1,:),...
                trajectory_timestamp(segment_end_id:next_start-1,:),writerObj)
        end

    else
        %line(hand_trajectory_xy(segment_end_id:end,1),...
        %hand_trajectory_xy(segment_end_id:end,2))
        plot_arm_trajectory(hand_trajectory_xy(segment_end_id:end,:),...
            elbow_trajectory_xy(segment_end_id:end,:),...
            shoulder_trajectory_xy(segment_end_id:end,:),...
            neck_trajectory_xy(segment_end_id:end,:),...
            trajectory_timestamp(segment_end_id:end,:),writerObj)
        
    end
    
end






