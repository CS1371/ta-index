%% convertToIndex: Converts the Excel Workbooks to JSON
%
% convertToIndex uses the information given to construct the TA index
%
% convertToIndex(B, H, F, S) will use the Basic TA information excel
% workbook path B, the Help Desk workbook path H, the Fun Facts
% workbook path F, and the Section information workbook S, to
% construct the TA index JSON (teachers.json).
%
% convertToIndex(B, H, F, S, T) will do the same as above, but
% will also use existing teacher JSON file T to handle the
% migration of existing fun facts.
%
%%% Remarks
%
% convertToIndex requires the workbooks meet the specifications as found
% in the README. However, if the given workbooks don't match, there will
% be an attempt to rectify this by passing them through the appropriate
% converter. Should that fail, an exception is thrown.
%
% Furthermore, it is necessary for the user to manually upload the
% resulting teachers.json file.
%
function convertToIndex(basic, help, fun, sections)

% make sure help and fun match - if not, convert
[~, ~, raw] = xlsread(help);
% format:
% * GT Username
% * Day
% * Start
% * Stop
headers = raw(1, :);
gtUser = strcmpi(headers, 'GT Username');
day = strcmpi(headers, 'Day');
start = strcmpi(headers, 'Start');
stop = strcmpi(headers, 'Stop');
if ~any(gtUser) || ~any(day) || ~any(start) || ~any(stop)
        % not correct format. Try to convert and try again
        % convert. Will throw error if cannot convert
        raw = help2standard(raw);
end
helpdesk = raw;

[~, ~, raw] = xlsread(fun);
% format:
% * GT Username
% * Question
% * Answer
headers = raw(1, :);
gtUser = strcmpi(headers, 'GT Username');
questions = strcmpi(headers, 'Question');
answers = strcmpi(headers, 'Answer');
if ~any(gtUser) || ~any(questions) || ~any(answers)
        % not correct - try to convert
        raw = fun2standard(raw);
end
funFacts = raw;

[~, ~, basicInfo] = xlsread(basic);
[~, ~, sectionsInfo] = xlsread(sections);

% Error correction - anything that is NaN needs to die

% Create TA array
headers = basicInfo(1, :);
gtUser = basicInfo(2:end, strcmpi(headers, 'GT Username'));
name = basicInfo(2:end, strcmpi(headers, 'Name'));
major = basicInfo(2:end, strcmpi(headers, 'Major'));
title = basicInfo(2:end, strcmpi(headers, 'Title'));
section = basicInfo(2:end, strcmpi(headers, 'Section'));

tas = struct('gtUsername', gtUser, 'name', name, 'major', major, 'title', title, 'section', section, 'funFacts', [], 'helpDesk', []);

% Decode sections
headers = sectionsInfo(1, :);
secNames = sectionsInfo(2:end, strcmpi(headers, 'name'));
secLocs = sectionsInfo(2:end, strcmpi(headers, 'location'));
secTimes = sectionsInfo(2:end, strcmpi(headers, 'time'));

secNames(end+1) = {''};
secLocs(end+1) = {''};
secTimes(end+1) = {''};

secData = struct('name', secNames, 'location', secLocs, 'time', secTimes);

for t = 1:numel(tas)
        tas(t).section = secData(strcmpi(secNames, tas(s).section));
end

% Decode helpdesk hours
%
% create helpdesk structure
headers = helpdesk(1, :);
gtUser = helpdesk(2:end, strcmpi(headers, 'GT Username'));
days = helpdesk(2:end, strcmpi(headers, 'Day'));
start = helpdesk(2:end, strcmpi(headers, 'Start'));
stop = helpdesk(2:end, strcmpi(headers, 'Stop'));

helpdesk = struct('gtUsername', gtUser, 'day', days, 'start', start, 'stop', stop);

% For each TA, collect all the helpdesk hours. Then, combine as necessary
for t = 1:numel(tas)
        tmp = helpdesk(strcmpi(gtUser, tas(t).gtUsername));
        % now, combine
        % if have the same day, AND start time of one = stop time of other (or vv), engage
        for (i = 1:numel(tmp))
                h1 = tmp(i);
                for j = numel(tmp):-1:(i+1)
                        h2 = tmp(j);
                        if strcmp(h1.day, h2.day) && strcmp(h1.stop, h2.start)
                                tmp(i).stop = h2.stop;
                                tmp(j) = [];
                        end
                end
        end

        % format helpdesks
        for i = 1:numel(tmp);
            tmp(i).time = [tmp(i).start ' pm - ' tmp(i).stop ' pm'];
        end
        tmp = rmfield(tmp, 'start');
        tmp = rmfield(tmp, 'stop');
        tas(t).helpDesk = tmp;
end
% Decode fun facts.
%
% NOTE. existing fun facts might already exist! If extra JSON file provided, read from them and parse as necessary.
end
