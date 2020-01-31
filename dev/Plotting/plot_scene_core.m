
% plot_scene_core.m
%core commands of plotting the objects, gabs and trajectories 

function object_rectangle_handles = plot_scene_core( table_pos,table_width,...
    table_depth,start_pos,start_width,scene_objects)


%figure
figure('units','normalized','outerposition',[0 0 1 1])
hold on
xlim([-4 4])
ylim([-7 4 ])

%plot the table
rectangle('Position',[table_pos(1)-table_width/2 ,...
    table_pos(2)-table_depth/2, table_width , table_depth],...
                'LineWidth',12,'EdgeColor','black')

%plot the starting point 'Home'
% rectangle('Position',[start_pos(1)-start_width/2 ,...
% start_pos(2)-start_depth/2, start_width , start_depth],...
% 'LineWidth',LW,'EdgeColor','green')
% text(start_pos(1), start_pos(2), 'H','FontSize',FS)
viscircles([start_pos(1) start_pos(2)],start_width/2,'Color','green',...
    'LineStyle','--','LineWidth',4); %

%plot objects in the scene and the target
%initialize vectors of info of all objects in the scene (including Target)
no_objects = size(scene_objects,1);
X = zeros(no_objects,1); Y = zeros(no_objects,1);
W = zeros(no_objects,1); H = zeros(no_objects,1);

object_rectangle_handles = [];
for ii = 1 : no_objects
    X(ii) = scene_objects(ii,1);
    Y(ii) = scene_objects(ii,3);
    W(ii) = scene_objects(ii,4);
    H(ii) = scene_objects(ii,6);
    
    if ii == 1
        %'T'arget
        %object_id = 'T';
        %text(plot_scale*X(ii), plot_scale*Y(ii), object_id,'FontSize',FS)
        rect_clr = 'green'; 
    else
        rect_clr = 'red';
        %text(X(ii)-0.1,Y(ii),['O' num2str(ii-1)],'FontSize',20)
    end
    object_rectangle_handles = [object_rectangle_handles;...
        rectangle('Position', [X(ii)-W(ii)/2 Y(ii)-H(ii)/2  W(ii)  H(ii)],...
        'LineWidth',8,'EdgeColor',rect_clr)];
    
end

% hold on
% if plot_trajectory_flag
%     %plot trajectory
%     line(plot_scale*trajectory_xy(:,1),plot_scale*trajectory_xy(:,2),'LineWidth',LW)
%     
%     %plot gabs
%     for ii = 1 : size(gabs,1)
%         rectangle('Position',plot_scale*gabs(ii,:),'EdgeColor','r','LineWidth',LW)
%     end
% end


