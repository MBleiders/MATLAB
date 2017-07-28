% close all
[fileID,message] = fopen('Z:\Manuals\Calibration\dbbc\old_dbbc_linearity_check\dbbctest_5.log', 'r');

log_file = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

%get line count:
numLines = size(log_file{1},1);% logfile total line count

data_point_count = 13;%different if att. value count
if_count = 4;%must have ifa
bbc_count = 16;%must have bbc01

column_count = 1 + if_count + bbc_count*2;
data_array = zeros(data_point_count, column_count);
k = 1;

%find if data
for i=1:numLines
    index = strfind(log_file{1}(i), '/ifa/');
    if index{1} > 0
        parsed_line = strsplit(char(log_file{1}(i)),',');
        data_array(k,1) = str2double(parsed_line(5));%att. value. takes only ifa value. assumtion that all if att. are equal
        data_array(k,2) = str2double(parsed_line(6));%ifa tp counts        
        for l = 1:(if_count - 1)
            parsed_line = strsplit(char(log_file{1}(i+l)),',');
            data_array(k,2+l) = str2double(parsed_line(6));%ifb..ifc tp counts            
        end
        k = k + 1;
    end  
end

k = 1;
%find bbc data
for i=1:numLines    
    index = strfind(log_file{1}(i), '/bbc01/');
    if index{1} > 0       
        for l = 0:(bbc_count-1)
            parsed_line = strsplit(char(log_file{1}(i+l)),',');
            data_array(k,6+2*l) = str2double(parsed_line(8));%usb tp
            data_array(k,7+2*l) = str2double(parsed_line(9));%lsb tp 
        end        
        k = k + 1;
    end 
end

figure(1)

colors = 'rgbc';
%plot if channels
for i = 2:(if_count + 1)
    plot(data_array(1:end,1), data_array(1:end,i), '.-','Color',colors(i-1));
    hold on
end
hold off
grid on
set(gca, 'YTickLabel', get(gca,'YTick')) 
title('IF total power');
ylabel('IF tp counts') % x-axis label
xlabel('att, 0.5 dB/count') % y-axis label

 legend({'IFA','IFB','IFC','IFD'});
lh=findall(gcf,'tag','legend');
set(lh,'location','northeastoutside');

figure(2)
semilogy(data_array(1:end,1), data_array(1:end,6), '.-', 'Color',colors(1));
hold on
semilogy(data_array(1:end,1), data_array(1:end,8), 'x-', 'Color',colors(1));
hold on
semilogy(data_array(1:end,1), data_array(1:end,10), 'o-', 'Color',colors(1));
hold on
semilogy(data_array(1:end,1), data_array(1:end,12), '*-', 'Color',colors(1));
hold on

semilogy(data_array(1:end,1), data_array(1:end,14), '.-', 'Color',colors(2));
hold on
semilogy(data_array(1:end,1), data_array(1:end,16), 'x-', 'Color',colors(2));
hold on
semilogy(data_array(1:end,1), data_array(1:end,18), 'o-', 'Color',colors(2));
hold on
semilogy(data_array(1:end,1), data_array(1:end,20), '*-', 'Color',colors(2));
hold on
semilogy(data_array(1:end,1), data_array(1:end,22), '.-', 'Color',colors(3));
hold on
semilogy(data_array(1:end,1), data_array(1:end,24), 'x-', 'Color',colors(3));
hold on
semilogy(data_array(1:end,1), data_array(1:end,26), 'o-', 'Color',colors(3));
hold on
semilogy(data_array(1:end,1), data_array(1:end,28), '*-', 'Color',colors(3));
hold on
semilogy(data_array(1:end,1), data_array(1:end,30), '.-', 'Color',colors(4));
hold on
semilogy(data_array(1:end,1), data_array(1:end,32), 'x-', 'Color',colors(4));
hold on
semilogy(data_array(1:end,1), data_array(1:end,34), 'o-', 'Color',colors(4));
hold on
semilogy(data_array(1:end,1), data_array(1:end,36), '*-', 'Color',colors(4));

hold off
set(gca, 'YTickLabel', get(gca,'YTick')) 
grid on
title('BBC upper sidebands');
ylabel('BBC tp counts') % x-axis label
xlabel('att, 0.5 dB/count') % y-axis label

legend({'bbc01','bbc02','bbc03','bbc04',...
    'bbc05','bbc06','bbc07','bbc08',...
    'bbc09','bbc10','bbc11','bbc12',...
    'bbc13','bbc14','bbc15','bbc16'});
lh=findall(gcf,'tag','legend');
set(lh,'location','northeastoutside');

clear all