

function overlap_measure = overlap_arbitrary_line_rectangle(line_segment, ...
    line_region_start,line_region_end , rectangle_objects, scan_resolution,line_orient,flip_trig)

Xi = line_segment(1,1); Yi = line_segment(1,2);
Xf = line_segment(end,1); Yf = line_segment(end,2); 
% line(10*[Xi Xf] ,10*[Yi Yf] ,'Color','r');

% dx = Xf-Xi;
% dy = Yf-Yi;
% line_orient = atan2(dy,dx);

if flip_trig == 1
    X_trig = cos(line_orient);
    Y_trig = sin(line_orient);
else
    X_trig = sin(line_orient);
    Y_trig = cos(line_orient);
end

line_step = (line_region_start+line_region_end)/scan_resolution;
sin_step = line_step* X_trig;
cos_step = line_step* Y_trig;

Xi_min = Xi - line_region_start * X_trig;
Xi_max = Xi + line_region_end * X_trig;
Yi_min = Yi - line_region_start * Y_trig;
Yi_max = Yi + line_region_end * Y_trig;

if Xi_min == Xi_max
    Xi_span = ones(scan_resolution,1)*Xi_min;
else
    Xi_span = Xi_min: sin_step : Xi_max;
end

if Yi_min==Yi_max
    Yi_span = ones(scan_resolution,1)*Yi_min;
else
    Yi_span = Yi_min: cos_step : Yi_max;
end

Xf_min = Xf - line_region_start * X_trig;
Xf_max = Xf + line_region_end * X_trig;
Yf_min = Yf - line_region_start * Y_trig;
Yf_max = Yf + line_region_end * Y_trig;
if Xf_min == Xf_max
    Xf_span = ones(scan_resolution,1)*Xf_min;
else
    Xf_span = Xf_min: sin_step : Xf_max;
end
if Yf_min==Yf_max
    Yf_span = ones(scan_resolution,1)*Yf_min;
else
    Yf_span = Yf_min: cos_step : Yf_max;
end
N_obj = size(rectangle_objects,1);
intersection_status = zeros(scan_resolution, N_obj);
xmin = ones(scan_resolution,N_obj)*1e5; ymin= ones(scan_resolution,N_obj)*1e5;
xmax = ones(scan_resolution,N_obj)*-1e5; ymax= ones(scan_resolution,N_obj)*-1e5;

%construct scan lines in the specified region
N_lines =min(min(length(Xi_span),length(Yi_span)),...
    min(length(Xf_span),length(Yf_span)));


for ii = 1 : N_lines
    
    scan_line = [Xi_span(ii) Yi_span(ii);...
        Xf_span(ii) Yf_span(ii)];
    
    %plot
%     line(10*[Xi_span(ii) Xf_span(ii)] , 10*[Yi_span(ii) Yf_span(ii)],'LineWidth',3);
    
    %iterate on all given occluding objects
    %find intersection betwen each scan line and each occluding object
    for jj = 1 : N_obj
        [intersection_status(ii,jj), xmin(ii,jj), xmax(ii,jj), ymin(ii,jj), ymax(ii,jj)] =...
            overlap_arbitrary_oriented_line_rectangle (scan_line , rectangle_objects(jj,:));
    end
end

%find the approximate intersection area of the scan line with each
%rectangle object
approx_intersection = zeros(N_obj,1);    
for jj = 1 : N_obj
    if sum(intersection_status(:,jj))>0
        idx = intersection_status(:,jj)==1;
        XMIN = min(xmin(idx,jj)); YMIN = min(ymin(idx,jj));
        XMAX = max(xmax(idx,jj)); YMAX = max(ymax(idx,jj));
%         rectangle('Position',10*([XMIN YMIN XMAX-XMIN YMAX-YMIN]),'EdgeColor','red');
        approx_intersection(jj)= (XMAX-XMIN)*(YMAX-YMIN)/(rectangle_objects(jj,3)*rectangle_objects(jj,4));
    end
end
    
% overlap_measure = sum(intersection_status(:))/(scan_resolution*N_obj);
overlap_measure = sum(approx_intersection)/N_obj;

end


function [intersection_status, xmin, xmax, ymin, ymax]= ...
    overlap_arbitrary_oriented_line_rectangle (line_segment , rect_cent_format)

% rectnagles assumed to be given in center_format
rect_bl_format = to_matlab_rectangles(rect_cent_format);
%rectangle X and Y edges
Xs_rect = rect_bl_format(1);
Xe_rect = Xs_rect + rect_bl_format(3);
Ys_rect = rect_bl_format(2);
Ye_rect =Ys_rect + rect_bl_format(4);

%X and Y oints in the line segment
X_line = linspace(line_segment(1,1), line_segment(2,1), 50);
Y_line = linspace(line_segment(1,2), line_segment(2,2), 50);

Xi = logical(X_line>=Xs_rect);
Xf = logical(X_line<=Xe_rect);
Yi = logical(Y_line>=Ys_rect);
Yf = logical(Y_line<=Ye_rect);
intersection_ids = Xi & Xf & Yi & Yf;

if any(intersection_ids)
    xmin = min(X_line(intersection_ids));
    xmax = max(X_line(intersection_ids));
    ymin = min(Y_line(intersection_ids));
    ymax = max(Y_line(intersection_ids));
    intersection_status = 1;
else
    xmin=0;xmax=0;
    ymin=0;ymax=0;
    intersection_status = 0;
end

end

