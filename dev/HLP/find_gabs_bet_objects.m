
%find_gabs_bet_objects.m
%find gaps betwen the objects in the scene
%X,Y,W,H: position of the center (X,Y) and size (W,H) of objects including target
%table_left_edge,table_right_edge: edges of the table/shelve in X-coordinates
%gabs: matrix of rectangles describing the gabs

%Inputs:
% obj_rect_cent_format: object recatngles in center format 
% table_edges: structure of table left, right, top and bottom edges
% object_depth: depth of objects in the scene

%Outputs:
%gap_rectangles : arrays of gab rectangles
%row_heights: heights of the rows where object exist
% gap_row_ids: IDs telling to which row an object belongs

function [gap_rectangles, row_heights, gap_row_ids] = find_gabs_bet_objects...
    (obj_rect_cent_format,table_edges,object_depth)

%object rectangles are in center-format
X_objects = obj_rect_cent_format(:,1);
Y_objects = obj_rect_cent_format(:,2);
W_objects = obj_rect_cent_format(:,3);
% H_objects = obj_rect_cent_format(:,4);

%find how many rows of objects
row_heights = unique(Y_objects);
n_rows = length(row_heights);

%initialize gabs
gap_rectangles = [];

%find the gabs 
for ii = 1 : n_rows

    object_ids = find(Y_objects==row_heights(ii));
    %X and W of these objects
    X_obj_row = X_objects(object_ids);
    W_obj_row = W_objects(object_ids);
    
    %compute edges of these objects
    object_edges = zeros(2*length(object_ids),1);
    for jj = 1 : length(object_ids)
        object_edges(2*jj - 1) = X_obj_row(jj) - W_obj_row(jj)/2;
        object_edges(2*jj) = X_obj_row(jj) + W_obj_row(jj)/2;
    end
    object_edges = sort(object_edges);
    
    %compute the gabs between objects in this row
    gabs_X_limits = [table_edges.left object_edges(1)];
    for jj = 1 : (length(object_edges)-2)/2
        gabs_X_limits = [gabs_X_limits; object_edges(2*jj) object_edges(2*jj+1)];
    end
    gabs_X_limits = [gabs_X_limits; object_edges(end) table_edges.right];
    
    gap_rectangles = [gap_rectangles; 
        gabs_X_limits(:,1)  row_heights(ii)-object_depth/2*ones(size(gabs_X_limits,1),1)  gabs_X_limits(:,2)-gabs_X_limits(:,1)  object_depth*ones(size(gabs_X_limits,1),1)]; 
end

%to which row each object belongs
gap_row_ids = zeros(size(gap_rectangles,1),1);
gap_heights = gap_rectangles(:,2);
unique_gap_heights = unique(gap_heights);
for ii = 1 : length(unique_gap_heights)
    idx = gap_heights == unique_gap_heights(ii);
    gap_row_ids(idx) = ii;
end
