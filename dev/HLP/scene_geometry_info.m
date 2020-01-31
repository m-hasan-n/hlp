%Information of the scene (table and objects) dimensions

function [hand_width, table_obj , start_obj, target_obj, object_depth,...
    virtual_objects]=scene_geometry_info()


%Table
table_obj.pos =[0 -0.05];
table_obj.width = 0.74;
table_obj.depth = 0.60;
table_obj.diagonal= ((table_obj.width)^2 + (table_obj.depth)^2)^0.5;
table_obj.area = table_obj.width * table_obj.depth;
table_obj.edges.left = table_obj.pos(1)- table_obj.width/2;
table_obj.edges.right = table_obj.pos(1)+ table_obj.width/2;
table_obj.edges.bottom = table_obj.pos(2)- table_obj.depth/2;
table_obj.edges.top = table_obj.pos(2)+ table_obj.depth/2;

%Start
start_obj.width = 0.05;
start_obj.depth = 0.05;

%Target
target_obj.width = 0.05;
target_obj.depth = 0.05;

%object's depth is fixed in this version
object_depth = 0.05;

%hand dimensions
hand_width = 0.05; 

%virtual objects surrounding the edges of the table
%these objects will be included in computation of free spcae around objects
w = table_obj.width;
h = table_obj.depth;
x = table_obj.pos(1)-w/2;
y = table_obj.pos(2)-h/2;
d = object_depth;

virtual_objects = [x-d y+h w+2*d d; %top wall
                   x-d y d h; %left wall
                   x+w y d h; %right wall
                   x-d y-d w+2*d d]; %bottom wall is open but should be 
                                     %included when training object moving
