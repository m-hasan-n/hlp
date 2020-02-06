


function new_loc_cent_format = object_location_movement(object_cent_format , mov_dir, scaling_factor)

object_BL_format = to_matlab_rectangles(object_cent_format);
x = object_BL_format(1);
y = object_BL_format(2);
w = object_BL_format(3);
h = object_BL_format(4);

%for FF,BB, RR, LL
%change distance a little bit to avoid aligned positions that cause later
%computational problems e.g. div. by zero
safety_factor = 0.2;

switch mov_dir
    case 'FF'
        new_loc_BL_format = [x-safety_factor*w y+h w scaling_factor*h];
    case 'BB'
        new_loc_BL_format = [x-safety_factor*w y-scaling_factor*h w scaling_factor*h];
    case 'LL'
        new_loc_BL_format = [x-scaling_factor*w y+safety_factor*h scaling_factor*w h];
    case 'RR'
        new_loc_BL_format = [x+w y+safety_factor*h scaling_factor*w h];
    case 'FR'
        new_loc_BL_format = [x+w y+h scaling_factor*w scaling_factor*h];
    case 'FL'
        new_loc_BL_format = [x-scaling_factor*w y+h scaling_factor*w scaling_factor*h];
    case 'BR'
        new_loc_BL_format = [x+w  y-scaling_factor*h scaling_factor*w scaling_factor*h];
    case 'BL'
        new_loc_BL_format = [x-scaling_factor*w y-scaling_factor*h scaling_factor*w scaling_factor*h];
end

new_loc_cent_format = to_rectangles_cent_format(new_loc_BL_format);


end
