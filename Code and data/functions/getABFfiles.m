function [data_all] = getABFfiles(datadir, channelN)

%Function for finding and extracting treadmill data (i.e., rotary encoder voltage signal) from abf files acquired with Clampex software

cd(datadir); %Jump to folder with data
fstruct = dir('*.abf'); %Get info for abf files in directory
FileNames = {fstruct.name}; %Extract file names for abf files 

inputChannel = ['IN ' num2str(channelN) ''];

for i = 1:length(FileNames)
    
    temp_file = fullfile(datadir,FileNames{1,i}); %File path
    [d, si, h] = abfload2(temp_file); %Load abf file
    
    %Grab the column in d that matches the specified input channel    
    log = startsWith(h.recChNames,inputChannel); %Find index of channel name column that matches specified input channel
    [M,I] = find(log == 1); %Grab the index of where the log == 1 

    %Get sampling rate
    sampRate = 1*10^6/si; %Define frequency

    %Store data into structure
    data_all.treadmill{1,i} = d(:,I);
    data_all.sampRate{1,i} = sampRate;
    data_all.h{1,i} = h;
    
    %Throw an warning message if data is empty
    if isempty(data_all.treadmill{1,1}) == 1
        disp('Looks like you got the wrong channel input specified')
    else
        disp('Reading data in')
    end
    
    
end

end

