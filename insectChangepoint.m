
% for k = 1:length(adjusted_data_decembercal)
k = 47;

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

% disp(k)
% disp(insectPos)
% end

%% 07/06/2022
%{
Put the conditionals into a function called iptFilter
Deleted the unused resize, fourier transform, second wavelet transform.
Also got rid of unused if-statement (3 left)
Want to add something that plots original signal and verifies that there is
a spike/change where the detected changepoint is
%}
%% 07/05/2022
%{
Put all of the cropping into functions
%}
%% 07/01/2022
%{
Added if statements 1-4 to hopefully decrease performance time and stuffs
and also ensure that it always gives an output when put into a function
Normalized tempSignal to increase contrast and adjusted changepoint
threshold accordingly

%}
%% 06/30/2022
%{
Commented out everything related to Fourier transform, I don't think it's
needed
%}
%% 06/29/2022
%{
If looking at difference between wavelet transforms of img and fourierImg,
take the absolute value of the difference matrix, and then threshold it to
60-70% of the max value to try to isolate the insect signal a bit more
Stuff above the threshold right before insect signal???
^^NOT TRUE
%}
%% 06/28/2022
%{
Added Wavelet transform section
Added look at change in remaining rows
Added variable imgRow that keeps track of which insect rows are kept from
original image
%}
%% 06/24/2022
%{
Re-organized order to: use resize, remove empty rows, remove hardpoints,
Fourier transform
Added findchangepts
%}
%% 06/22/2022
%{
Created file
Wrote remove empty rows, Fourier transform, remove hardpoints
%}