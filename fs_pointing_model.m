close all

[fileID,message] = fopen('mdlpo.ctl', 'r');

mdlpo = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

%get line count:
numLines = size(mdlpo{1},1);
P = zeros(30,1);

data_offset = 2;
actual_data_line_count = 0;
d = 0;

for i = 1:numLines
    line = char(mdlpo{1}(i));
    
    %skip commented lines
    if line(1) == '*'
        continue;
    else
        actual_data_line_count = actual_data_line_count + 1;
        
        %skip date and '1 1 1..' lines
        if actual_data_line_count > data_offset
            split_values = strsplit(line);
            
            for m = 1:5
                d = d + 1;
                P(d) = str2double(split_values(m));
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P1  = X-angle Encoder Offset
% P2  = X-angle Sag
% P3  = Axis SKew
% P4  = Box Offset
% P5  = Tilt Out (tilt of Y=+90 toward X,Y=0,0)
% P6  = Tilt Over (tilt of Y=+90 toward X,Y=90,0)
% P7  = Y-Angle Encoder Offset
% P8  = Y-Angle Sag
% P9  = ad hoc Y-angle slope (degrees/radian)
% P10 = ad hoc Y-angle cos(Y) term
% P11 = ad hoc Y-angle sin(Y) term
% P12 = ad hoc X-angle slope (degrees/radian)
% P13 = ad hoc X-angle cos(X) term
% P14 = ad hoc X-angle sin(X) term
% P15 = ad hoc Y-angle cos(2*X) term
% P16 = ad hoc Y-angle sin(2*X) term
% P17 = ad hoc X-angle cos(2*X) term
% P18 = ad hoc X-angle sin(2*X) term
% P19 = ad hoc Y-angle cos(8*Y) term
% P20 = ad hoc Y-angle sin(8*Y) term
% P21 = ad hoc Y-angle cos(X) term
% P22 = ad hoc Y-angle sin(X) term
step_size = 1;
az_angles = 0:step_size:360;
el_angles = 0:step_size:85;
count_az = size(az_angles,2);
count_el = size(el_angles,2);

az_offsets = zeros(count_el,count_az);
el_offsets = zeros(count_el,count_az);

%Phi = elevation angle of +Y axis (postive from Y=+90 to X,Y=0,0)
Phi = 90*pi/180;

for az = 1:count_az

    for el = 1:count_el
        
    X = az_angles(az)*pi/180;
    Y = el_angles(el)*pi/180;
    
    Delta_X =  P(1) - P(2)*cos(Phi)*tan(Y) + P(3)*tan(Y) - P(4)/cos(Y)...
         + P(5)*sin(X)*tan(Y) - P(6)*cos(X)*tan(Y)...
         + P(12)*X + P(13)*cos(X) + P(14)*sin(X) + P(17)*cos(2*X) + P(18)*sin(2*X);

    Delta_Y =  P(5)*cos(X) + P(6)*sin(X)...
         + P(7) - P(8)*(cos(Phi)*sin(Y)*cos(X)-sin(Phi)*cos(Y)) + P(9)*Y...
         + P(10)*cos(Y) + P(11)*sin(Y) + P(15)*cos(2*X) + P(16)*sin(2*X)...
         + P(19)*cos(8*Y) + P(20)*sin(8*Y) + P(21)*cos(X) + P(22)*sin(X);
    
     az_offsets(el,az) = Delta_X;
     el_offsets(el,az) = Delta_Y;
    end
end

figure(1)
contourf(az_offsets, 30)
ylabel('El, deg');
xlabel('Az, deg');
title('Model of azimuth offset');
colorbar

figure(2)
contourf(el_offsets, 30)
ylabel('El, deg');
xlabel('Az, deg');
title('Model of elevation offset');
colorbar