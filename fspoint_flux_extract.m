% close all
[fileID,message] = fopen('point_96.log', 'r');

log_file = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

%get line count:
numLines = size(log_file{1},1);% logfile total line count
% numLines = 300;

k = 0;
%find onoff result line count
for i=1:numLines
    index = strfind(log_file{1}(i), '#onoff#VAL');
    if index{1} > 0
        k = k + 1;
    end  
end

sources = {'3c123', '3c196', '3c295', '3c286', '3c454.3', 'bllac', 'oj287'};

%time source flux_apr tcal(r) 
val_array_r = cell(k/2, 4);
val_array_l = cell(k/2, 4);

b = 0;
k = 0;
for i=1:numLines
    index = strfind(log_file{1}(i), '#onoff#VAL');
    if index{1} > 0
        if b ~= i
            b = i;
            k = k + 1;
            parsed_line = strsplit(char(log_file{1}(b)),' ');

                val_array_r{k,1} = parsed_line(1); %time
                val_array_r{k,2} = parsed_line(2); %source
                val_array_r{k,4} = parsed_line(13); %tcal ratio
            
            b = b + 1;%increment to lcp line
            parsed_line = strsplit(char(log_file{1}(b)),' ');

                val_array_l{k,1} = parsed_line(1); %time
                val_array_l{k,2} = parsed_line(2); %source
                val_array_l{k,4} = parsed_line(13); %tcal ratio

            %find apriori line index by going backwards 
            for m = i-1:-1:1
                index = strfind(log_file{1}(m), '#onoff#APR');
                if index{1} > 0
                    break;
                end
            end

            parsed_line = strsplit(char(log_file{1}(m)),' ');
            val_array_r{k,3} = parsed_line(5);%assumed flux is the same for both pols
            val_array_l{k,3} = parsed_line(5);

        end 
    end
end

%data ammount for sources may not be equal so just assume largest possible
%if only one source is used in session, it can be k values
flux_array_r = zeros(k, 3, size(sources, 2));
flux_array_l = zeros(k, 3, size(sources, 2));

%%%%%%%%%%%%%%%%do it for RCP
source_index_array = ones(size(sources, 2),1);%data ammount for sources may not be equal
for i = 1:k 
    source_match = 0;
   %determine current source index
   for s = 1:size(sources, 2)
       if strcmp(sources{s}, char(val_array_r{i,2}))
           source_match = 1;
           break;
       end
   end
   
   %if source did match with one of requested ones
   if source_match == 1
       parsed_line = strsplit(char(val_array_r{i,1}), '#');
       parsed_line = strsplit(char(parsed_line(1)), '.');
        
       %time value
       flux_array_r(source_index_array(s), 1, s) = ...
           datenum(strcat(datestr(doy2date(str2double(char(parsed_line(2))),...
           str2double(char(parsed_line(1))))), '.', parsed_line(3)),'dd-mmm-yyyy.HH:MM:SS');

       %Sf_apr, assumed flux value
       flux_array_r(source_index_array(s), 2, s) = str2double(char(val_array_r{i,3}));
       %Sf_actual = Sf_apr/Tcal_ratio;
       flux_array_r(source_index_array(s), 3, s) = ...
           flux_array_r(source_index_array(s), 2, s)/str2double(char(val_array_r{i,4}));
       
       source_index_array(s) = source_index_array(s) + 1;
   end
   
end

%%%%%%%%%%%%%%%%do it for LCP
source_index_array = ones(size(sources, 2),1);%data ammount for sources may not be equal
for i = 1:k 
    source_match = 0;
   %determine current source index
   for s = 1:size(sources, 2)
       if strcmp(sources{s}, char(val_array_l{i,2}))
           source_match = 1;
           break;
       end
   end
   
   %if source did match with one of requested ones
   if source_match == 1
       parsed_line = strsplit(char(val_array_l{i,1}), '#');
       parsed_line = strsplit(char(parsed_line(1)), '.');
        
       %time value
       flux_array_l(source_index_array(s), 1, s) = ...
           datenum(strcat(datestr(doy2date(str2double(char(parsed_line(2))),...
           str2double(char(parsed_line(1))))), '.', parsed_line(3)),'dd-mmm-yyyy.HH:MM:SS');

       %Sf_apr, assumed flux value
       flux_array_l(source_index_array(s), 2, s) = str2double(char(val_array_l{i,3}));
       %Sf_actual = Sf_apr/Tcal_ratio;
       flux_array_l(source_index_array(s), 3, s) = ...
           flux_array_l(source_index_array(s), 2, s)/str2double(char(val_array_l{i,4}));
       
       source_index_array(s) = source_index_array(s) + 1;
   end
   
end

source_index_array(:) = source_index_array(:) - 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%calculate statistics
stats_array = zeros(size(sources, 2), 2, 4);

for i = 1:size(sources, 2)
    stats_array(i, 1, 1) = mean(flux_array_r(1:source_index_array(i),3,i));
    stats_array(i, 1, 2) = std(flux_array_r(1:source_index_array(i),3,i));
    stats_array(i, 1, 3) = min(flux_array_r(1:source_index_array(i),3,i));
    stats_array(i, 1, 4) = max(flux_array_r(1:source_index_array(i),3,i));
    
    stats_array(i, 2, 1) = mean(flux_array_l(1:source_index_array(i),3,i));
    stats_array(i, 2, 2) = std(flux_array_l(1:source_index_array(i),3,i));
    stats_array(i, 2, 3) = min(flux_array_l(1:source_index_array(i),3,i));
    stats_array(i, 2, 4) = max(flux_array_l(1:source_index_array(i),3,i));
end

fprintf('%s\n', 'source    avg        std       min         max');
fprintf('%s\n', '      rcp   lcp   rcp  lcp  rcp   lcp   rcp   lcp');
for i = 1:size(sources, 2)
fprintf('%s %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f\n', char(sources(i)),...
    stats_array(i, 1, 1), stats_array(i, 2, 1),...
    stats_array(i, 1, 2), stats_array(i, 2, 2),...
    stats_array(i, 1, 3), stats_array(i, 2, 3),...
    stats_array(i, 1, 1), stats_array(i, 2, 4));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%filtering
filter_on = 1;

if filter_on == 1
    %if value differs from average by sigmas count std value, then replace it with average
    sigmas = 2;
    for i = 1:size(sources, 2)
        for j = 1:source_index_array(i)
            
            %RCP
            temp1 = stats_array(i, 1, 1) + sigmas*stats_array(i, 1, 2);
            temp2 = stats_array(i, 1, 1) - sigmas*stats_array(i, 1, 2);

            if flux_array_r(j,3,i) > temp1
                    flux_array_r(j,3,i) = -abs(flux_array_r(j,3,i));
            elseif flux_array_r(j,3,i) < temp2 
                    flux_array_r(j,3,i) = -abs(flux_array_r(j,3,i));
            end
            
            %LCP
            temp1 = stats_array(i, 2, 1) + sigmas*stats_array(i, 2, 2);
            temp2 = stats_array(i, 2, 1) - sigmas*stats_array(i, 2, 2);

            if flux_array_r(j,3,i) > temp1
                    flux_array_l(j,3,i) = -abs(flux_array_l(j,3,i));
            elseif flux_array_r(j,3,i) < temp2
                    flux_array_l(j,3,i) = -abs(flux_array_l(j,3,i));
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%plotting part

y_min = 0;
y_max = 25;

figure(1)
s = 1;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),2,s));
hold on
h1r = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
h1l = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');
s = 2;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),2,s));
hold on
h2r = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
h2l = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');
s = 3;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),2,s));
hold on
h3r = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
h3l = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');
% s = 4; %3c286 data very noisy
% plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),2,s));
% hold on
% h4r = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
% hold on
% h4l = plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');

grid on
grid minor
ylim([y_min y_max]);
ylabel('Sf, Jy');
xlabel('Time');
title(datestr(flux_array_r(1,1,1),'mmmm dd, yyyy'));
datetick('x','HH:MM','keepticks');
legend([h1r h1l h2r h2l h3r h3l],...
    {strcat(char(sources(1)),' rcp'),strcat(char(sources(1)),' lcp'),...
    strcat(char(sources(2)),' rcp'),strcat(char(sources(2)),' lcp'),...
    strcat(char(sources(3)),' rcp'),strcat(char(sources(3)),' lcp')});
% legend(char(sources(1)),char(sources(2)),char(sources(3)));

figure(2)
s = 5;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');
hold on
s = 6;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');
hold on
s = 7;
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_r(1:source_index_array(s),3,s), '.');
hold on
plot(flux_array_r(1:source_index_array(s),1,s), flux_array_l(1:source_index_array(s),3,s), '.');

grid on
grid minor
ylim([y_min y_max]);
ylabel('Sf, Jy');
xlabel('Time');
title(datestr(flux_array_r(1,1,1),'mmmm dd, yyyy'));
datetick('x','HH:MM','keepticks');
legend(strcat(char(sources(5)),' rcp'),strcat(char(sources(5)),' lcp'),...
    strcat(char(sources(6)),' rcp'),strcat(char(sources(6)),' lcp'),...
    strcat(char(sources(7)),' rcp'),strcat(char(sources(7)),' lcp'));


