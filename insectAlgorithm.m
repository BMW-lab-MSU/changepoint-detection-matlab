function bug = insectAlgorithm(data)

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

% for row = 24:24       % Debugging purposes
for row = 1:size(img,1)
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

    ipt = findchangepts(tempSignal,'Statistic','mean','MinThreshold',3.9);
    if ~isempty(ipt)
% Additional check by plotting original signal and seeing if there is still
% a changepoint at around the same spot
        ipt2 = findchangepts(normalize(smoothdata(img(row,:),'sgolay',20),'range'),'Statistic','mean','MinThreshold',3);
        if isempty(ipt2)
            % Do nothing
        else
% Check if time domain changepoints line up with wavelet changepoints
            newIpt = [];
            for i = 1:length(ipt2)
                iptDiff = abs(ipt - ipt2(i));
                [minDiff,idx] = min(iptDiff);
                if minDiff < 21         % < 21 means < 2% difference from wavelet changepoint, might need to change this tho
                    newIpt = [newIpt ipt(idx)];
                end
            end
            if ~isempty(newIpt)
                ipt = sort(newIpt);
% Implement iptFilter to verify changepoint and add/not add to insectPos
                insectPos = iptFilter(imgRow(row),tempSignal,ipt,insectPos);
            end
        end
    end
end

% Conditional to filter out fake changepoints
if ~isempty(insectPos)
    rowDiff = diff(insectPos(:,1));
    multiRows = unique(insectPos(rowDiff == 0,1));

    posDiff = diff(insectPos');
    tooBig = posDiff(2,:) > 605;
    tooSmall = posDiff(2,:) < 15;
    too = tooBig | tooSmall;
    tooRows = insectPos(too,1);
    insectPos(too,:) = [];

    for i = 1:length(multiRows)
        rows = insectPos(:,1);
        if ismember(multiRows(i),tooRows)
            insectPos(rows == multiRows(i),:) = [];
            tooRows(tooRows == multiRows(i)) = [];
        end
    end
end

end         % if statement #3 end
end         % if statement #2 end
end         % if statement #1 end

if ~isempty(insectPos)
    bug = [];
else
    bug = insectPos`;
end

end

