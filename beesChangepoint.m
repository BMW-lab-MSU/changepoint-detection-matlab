%{
Everything is the exact same as beesAlgorithm.m, but it is in a script
instead of a function so it is easier to use breakpoints and step through
everything.

You can either look at one image at a time (make sure to load the data you
want to look at first!), or uncomment the for loop (make sure to uncomment
'end' as well) to run through an entire dataset.

Some of the code was used for debugging purposes only, the comments show
where those are. Some notes for further improvment are also kept in this
file instead of the beesAlgorithm.m file.
%}

% for k = 1:length(adjusted_data_junecal)
k = 72;

data = adjusted_data_decembercal(k);
img = data.normalized_data;
imgRow = 1:178;
insectPos = [];
imgAvg = mean(mean(img));

%% Remove empty rows

[img,imgRow] = removeEmptyRows(img,imgRow);

%% Remove hard point rows

[img,imgRow] = removeHardTarget(img,imgRow,imgAvg);

if ~isempty(img)        % if statement #1 start
%% Look at change in each remaining row

[img,imgRow] = removeNoChange(img,imgRow);

if ~isempty(img)            % if statement #2 start
%% Wavelet Transform to get rid of bad rows

[img,imgRow] = removeWaveletRows(img,imgRow,data);

if ~isempty(img)            % if statement #3 start
%% Wavelet Transform on original image / changepoint detection
fs = 1/mean(diff(data.time));

% for row = 50:100       % Debugging purposes
for row = 1:size(img,1)
%     disp(row)
    tempWavelet = cwt(img(row,:),fs);
    tempWavelet = abs(tempWavelet);
    tempMax = max(max(tempWavelet));
    lesserValue = 0.225 * tempMax;
    tempWavelet(tempWavelet < lesserValue) = 0;
    tempWavelet = tempWavelet(1:40,:);
    tempWavelet = normalize(tempWavelet,'range');

    tempSignal = [];
    for col = 1:size(tempWavelet,2)
        colAvg = sum(tempWavelet(:,col)) / 40;
        tempSignal = [tempSignal colAvg];
    end
    tempSignal = smoothdata(tempSignal,'sgolay',40);
    tempSignal = normalize(tempSignal,'range');

    ipt = findchangepts(tempSignal,'Statistic','mean','MinThreshold',2);
    if ~isempty(ipt)
% Additional check by plotting original signal and seeing if there is still
% a changepoint at around the same spot
        rowSignal = normalize(smoothdata(img(row,:),'sgolay',20),'range');
        ipt2 = findchangepts(rowSignal,'Statistic','mean','MinThreshold',0.8);
        if isempty(ipt2)
            % Do nothing
        else
% Check if time domain changepoints line up with wavelet changepoints
            newIpt = [];
            for i = 1:length(ipt2)
                iptDiff = abs(ipt - ipt2(i));
                [minDiff,idx] = min(iptDiff);
                if minDiff < 100
                    newIpt = [newIpt ipt(idx)];
                end
            end
            if ~isempty(newIpt)
                ipt = sort(unique(newIpt));
% Implement iptFilter to verify changepoint and add/not add to insectPos
                insectPos = iptFilter([row imgRow(row)],tempSignal,ipt2,insectPos);
            end
        end
    end
end

%% Conditional to filter out changepoints that are too long/short
if ~isempty(insectPos)
    rowDiff = diff(insectPos(:,2));
    multiRows = unique(insectPos(rowDiff == 0,1));

% Get rid of changepoints that are too big or too small
    posDiff = diff(insectPos');
    tooBig = posDiff(3,:) > 700;    % Might need to change; there are insects longer than 700
    tooSmall = posDiff(3,:) < 15;   % and shorter than 15 (blips and stuff)
    too = tooBig | tooSmall;
    tooRows = insectPos(too,2);
    insectPos(too,:) = [];

% Get rid of the other changepoints in the same row as above
    for i = 1:length(multiRows)
        rows = insectPos(:,2);
        if ismember(multiRows(i),tooRows)
            insectPos(rows == multiRows(i),:) = [];
            tooRows(tooRows == multiRows(i)) = [];
        end
    end
end

%% Group insect rows into individual insects
% Doesn't have to be perfect, purpose of this is to weed out false
% positives and set up the data for the last layer of filtering
if ~isempty(insectPos)
    insects = {};
    idx = 1;
    insectNum = 1;
    
    insects{insectNum} = insectPos(idx,:);
    idx = idx+1;
    insectNum = insectNum + 1;
    
    while idx <= size(insectPos,1)
        for i = 1:length(insects)
            if diff([insects{i}(1,2) insectPos(idx,2)]) < 14 && ...
               sum(abs(diff([insects{i}(end,3:4);insectPos(idx,3:4)])) < 20) > 0
                insects{i} = [insects{i};insectPos(idx,:)];
                idx = idx+1;
                break;
            else
                insects{insectNum} = insectPos(idx,:);
                idx = idx+1;
                insectNum = insectNum+1;
                break
            end
        end
    end

%% Plot vertical signals and find local max to verify peak
% needs to be refined, somehow get the median location in the signal?
% plotting in the middle doesn't do justice and plotting the highest value
% signal makes it biased
% Should it check the original image or just stay at the image it's at
% right now? How much will hardpoints in the image affect its performance?

    for i = 1:length(insects)
        validInsect = false;
        insectStart = max(insects{i}(:,3));
        insectEnd = min(insects{i}(:,4));
        middle = round(mean([insectStart insectEnd]));
        [~,idx] = max(max(img(insects{i}(1,1):insects{i}(end,1),middle-1:middle+1)));
        col = mod(idx,3);
        if col == 0
            col = 3;
        end
        col = col + middle - 2;
        columnSignal = normalize(img(:,col),'range');
        [TF1,P] = islocalmax(columnSignal,'MinProminence',0.6);
        peakRows = find(TF1);
        if idx < 4
            peakRows = [1;peakRows];
        end
        if isempty(peakRows)
            insects{i} = [];
            continue;
        elseif length(peakRows) > 6
            insects{i} = [];
            continue;
        end
        rows = insects{i}(:,1);
        for j = 1:length(peakRows)
            peakDiff = rows - peakRows(j);
            if sum(peakDiff == 0) > 0
                validInsect = true;
                break;
            end
        end
        if ~validInsect
            insects{i} = [];
        end
    end
    
    insectPos = [];
    for i = 1:length(insects)
        insectPos = [insectPos;insects{i}(:,2:end)];
    end

end         % if ~isempty(insectPos) end

end         % if statement #3 end
end         % if statement #2 end
end         % if statement #1 end

% disp(k)
% disp(insectPos)
% end