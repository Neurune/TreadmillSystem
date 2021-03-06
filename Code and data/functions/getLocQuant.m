
function [locomotionQuant] = getLocQuant(speed,threshold, interval, duration, ToPlotOrNot)

%Function for analyzing speed trace

for k = 1:length(speed.smooth)

%Grab data    
temp_speed = speed.smooth{1,k};
temp_sampRate = speed.sampRate{1,k};
temp_timeS = speed.time_sec{1,k};

%% Find locomotion bouts 

%Binarize speed trace based on speed threshold
running_binary =[];
for i = 1:length(temp_speed) 
    if temp_speed(i) > threshold  
        running_binary(i) = 1;
    else
        running_binary(i) = 0;
    end 
end

%If less than X s between running offset and next onset, running onset is removed
CC = bwconncomp(running_binary == 0);
running_binary_cleaned=running_binary;
for i=1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{i}) < interval*temp_sampRate; 
        running_binary_cleaned(CC.PixelIdxList{i}(1):CC.PixelIdxList{i}(end)) = 1;
    end
end

%Remove running bouts shorter than X s
CC2 = bwconncomp(running_binary_cleaned == 1);
running_binary_cleaned2 = running_binary_cleaned;
for i=1:length(CC2.PixelIdxList)
    if length(CC2.PixelIdxList{i}) < duration*temp_sampRate; 
        running_binary_cleaned2(CC2.PixelIdxList{i}(1):CC2.PixelIdxList{i}(end)) = 0;
    else
    end
end

locomotion_on = [];
locomotion_off = [];
%Get run onset and offset id for each locomotion bout
CC3 = bwconncomp(running_binary_cleaned2 == 1);
for i = 1:length(CC3.PixelIdxList)
    locomotion_on(i) = CC3.PixelIdxList{i}(1);
    locomotion_off(i) = CC3.PixelIdxList{i}(end); 
end

%% Quantifications

%Locomotion distance during first 10 min of recording
locomotionQuant.distSimple{1,k} = (trapz(temp_timeS(1:temp_sampRate*60*10+1), temp_speed(2:temp_sampRate*60*10+2)))/100; %Distance travelled during the first 10 min (used across recordings for comparison) in meters

%Locomotion bout analysis
for i=1:length(locomotion_on)
   
   %Grab data 
   trace_temp = temp_speed(locomotion_on(i):locomotion_off(i));
   dtime_temp = 1/temp_sampRate;
   time_temp =  ((0:length(trace_temp)-1)*dtime_temp)';
   
   %Compute locomotor distance for each bout
   locomotionQuant.boutDist{i,k} = trapz(time_temp, trace_temp);
   
   %Computer mean and maximal locomotor speed for each bout
   locomotionQuant.maxSpeed{i,k} = max(trace_temp);
   locomotionQuant.meanSpeed{i,k} = mean(trace_temp);

   %Compute bout duration
   locomotionQuant.boutDur{i,k} = time_temp(end);
   
end

%Get percentage of time spent locomoting
locomotionQuant.percLoc{1,k} = sum(cell2mat(locomotionQuant.boutDur(:,k)))/temp_timeS(end,1)*100; %In percentage 


%% Generate analysis plots

    if ToPlotOrNot == 1;
        
        %Make plot showing treadmill speed and running bouts to assess that analysis criteria works as expected 
        temp_speed_norm = (temp_speed - min(temp_speed)) / (max(temp_speed)-min(temp_speed));
        
        figure(2)
        subplot(length(speed.smooth),1,k);
        hold all;
        plot(temp_timeS, temp_speed_norm, 'r', 'LineWidth',2)
        plot(temp_timeS, running_binary_cleaned2, 'k', 'LineWidth', 1)
        axis([-inf inf 0 1.2])
        title("Habituation session # " + k + "");
        ylabel('Speed [norm]')
        
        if k == length(speed.smooth)
            xlabel('Time [s]')
        else
        end

    else
    end

end

    if ToPlotOrNot == 1;
       
        %Make plot showing locomotion distance during first 10 min of recording session across days
        x = 1:1:length(speed.smooth);
        y = cell2mat(locomotionQuant.distSimple);
        figure(3)
        h = plot(x,y, '-ok','MarkerFaceColor','k', 'MarkerSize',14)
        xlim([0 x(end)+1])
        ylim([min(y)*0.5 max(y)*1.5])
        xticks([x])
        ylabel('Distance/10 min [m]')
        xlabel('Habituation session [#]')

        %Make plot showing percentage of time spent locomoting
        x = 1:1:length(speed.smooth);
        y = cell2mat(locomotionQuant.percLoc);
        figure(4)
        h = plot(x,y, '-ok','MarkerFaceColor','k', 'MarkerSize',14)
        xlim([0 x(end)+1])
        ylim([min(y)*0.5 max(y)*1.5])
        xticks([x])
        ylabel('Time locomoting [%]')
        xlabel('Habituation session [#]')
        
        %Make ploting showing mean speed during locomotion bouts
        x = 1:1:length(speed.smooth);
        for p = 1:size(locomotionQuant.meanSpeed,2)
           y_temp = cell2mat(locomotionQuant.meanSpeed(:,p));
           Mean(1,p) = nanmean(y_temp);
           SD(1,p) = nanstd(y_temp); 
        end
        
        figure(5)
        errorbar(x,Mean,SD, '-ok', 'MarkerFaceColor','k', 'MarkerSize',14)
        xlim([0 x(end)+1])
        
        Max = max(Mean+SD);
        Min = min(Mean-SD);
        
        if Min < 0
           ylim([Min*1.25 Max*1.25])
        else
           ylim([Min*0.75 Max*1.25])
        end
        
        xticks([x])
        ylabel('Average speed during locomotion bout [cm/s]')
        xlabel('Habituation session [#]')
        
        %Make plot showing max speed during locomotion bouts
        x = 1:1:length(speed.smooth);
        for p = 1:size(locomotionQuant.maxSpeed,2)
           y_temp = cell2mat(locomotionQuant.maxSpeed(:,p));
           Max(1,p) = nanmean(y_temp);
           SD(1,p) = nanstd(y_temp); 
        end
        
        figure(6)
        errorbar(x,Max,SD, '-ok', 'MarkerFaceColor','k', 'MarkerSize',14)
        xlim([0 x(end)+1])
        Max2 = max(Max+SD);
        Min = min(Max-SD);
        
        if Min < 0
           ylim([Min*1.25 Max2*1.25])
        else
           ylim([Min*0.75 Max2*1.25])
        end
        
        xticks([x])
        ylabel('Maximum speed during locomotion bout [cm/s]')
        xlabel('Habituation session [#]')
        
        %Make plot showing average locomotion bout duration
        x = 1:1:length(speed.smooth);
        for p = 1:size(locomotionQuant.boutDur,2)
           y_temp = cell2mat(locomotionQuant.boutDur(:,p));
           Mean(1,p) = nanmean(y_temp);
           SD(1,p) = nanstd(y_temp); 
        end
        
        figure(7)
        errorbar(x,Mean,SD, '-ok', 'MarkerFaceColor','k', 'MarkerSize',14)
        xlim([0 x(end)+1])        
        Max = max(Mean+SD);
        Min = min(Mean-SD);
        
        if Min < 0
           ylim([Min*1.25 Max*1.25])
        else
           ylim([Min*0.75 Max*1.25])
        end
        
        xticks([x])
        ylabel('Average locomotion bout duration [s]')
        xlabel('Habituation session [#]')

    else
    end

end