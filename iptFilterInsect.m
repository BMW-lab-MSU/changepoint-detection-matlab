function insectPos = iptFilterInsect(row,tempSignal,ipt,insectPos)

% This function assumes that there are a maximum of two insects in each
% row. Changes are needed if there's more; no easy way at the moment to be
% able to identify three insects.

signalThresh = 0.27;

if length(ipt) == 1         % one changepoint
    mean1 = mean(tempSignal(1:ipt));
    mean2 = mean(tempSignal(ipt:end));
    means = [mean1 mean2];
    if sum(means < signalThresh) == 2
%         disp("no bug1")
    elseif sum(means > signalThresh) == 2
%         disp("no bug2")
    else
        if mean1 > mean2
            insectPos = [insectPos; row 1 ipt];
        else
            insectPos = [insectPos; row ipt 1024];
        end
    end
elseif length(ipt) == 2     % two changepoints
    mean1 = mean(tempSignal(1:ipt(1)));
    mean2 = mean(tempSignal(ipt(1):ipt(2)));
    mean3 = mean(tempSignal(ipt(2):end));
    means = [mean1 mean2 mean3];
    if sum(means < signalThresh) == 3
%         disp("no bug3")
    elseif sum(means > signalThresh) == 3
%         disp("no bug4")
    elseif (mean1 < signalThresh) && (mean3 < signalThresh)
        insectPos = [insectPos; row ipt(1) ipt(2)];
    elseif (mean1 > signalThresh) && (mean2 > signalThresh)
        insectPos = [insectPos; row 1 ipt(2)];
    elseif (mean2 > signalThresh) && (mean3 > signalThresh)
        insectPos = [insectPos; row ipt(1) 1024];
    elseif (mean1 > signalThresh) && (mean3 > signalThresh)
        if abs(mean1 - mean3) < 0.1
            insectPos = [insectPos; row 1 ipt(1)];
            insectPos = [insectPos; row ipt(2) 1024];
        end
    else
%         disp("no bug5")
    end
elseif length(ipt) > 2      % 3 or more changepoints
    tempIpt = [1 ipt 1024];
    means = [];
    for i = 1:length(tempIpt) - 1
        means = [means mean(tempSignal(tempIpt(i):tempIpt(i+1)))];
    end
    if sum(means > signalThresh) == length(means)
%         disp("no bug6")
    else
% Look at relative difference between means, find the smallest change, then
% remove that least significant changepoint and recursively call iptFilter
        iptPercentDiff = abs(means(2) - means(1)) / means(1);
        for i = 2:length(means)-1
            iptPercentDiff = [iptPercentDiff (abs(means(i-1)-means(i))+abs(means(i+1)-means(i)))/(2*means(i))];
            %{
            Quick maths^^:
                1/2 * [(|a-b|)/b + (|c-b|)/b]
            =   1/2 * [(|a-b|+|c-b|)/b]
            =   (|a-b|+|c-b|)/(2b)
            %}
        end
        iptPercentDiff = [iptPercentDiff abs(means(end)-means(end-1))/means(end)];

        [~,minIdx] = min(iptPercentDiff);
        
        if minIdx == 1
            ipt = ipt(2:end);
            insectPos = iptFilter(row,tempSignal,ipt,insectPos);
        elseif minIdx == length(iptPercentDiff)
            ipt = ipt(1:end-1);
            insectPos = iptFilter(row,tempSignal,ipt,insectPos);
        else
            [~,less] = min([abs(means(minIdx)-means(minIdx-1)) abs(means(minIdx+1)-means(minIdx))]);
            ipt = [ipt(1:minIdx+less-3) ipt(minIdx+less-1:end)];
            insectPos = iptFilter(row,tempSignal,ipt,insectPos);
        end
    end
end

end
