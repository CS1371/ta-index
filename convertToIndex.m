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
% J = convertToIndex(_) will do the same as above - however, instead of
% creating teachers.json, the JSON is output in the structure array J.
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
function json = convertToIndex(basic, help, fun, sections, previous)
    DEFAULT_QUESTIONS = {'Favorite Matlab Function', ...
        'Favorite Hashtag', 'Favorite Homework Problem', ...
        'Hobbies', 'Most embarrassing story from middle school', ...
        'Team sum(mask) or team length(vec(mask))', ...
        'Pro switch or anti switch', ...
        'Most embarrassing recitation story', ...
        'Which team are you on?', 'Favorite quote', ...
        'Advise to your 5th grade self', ...
        'I cry while grading tests when...', 'Favorite Song', ...
        'I am the best in the world at:', 'Mac (*barf*) or PC?', ...
        'This one time at band camp...', ...
        'When I was 5 years old, I wanted to be a...', ...
        'Advise to yourself while you were taking the class', 'Best Joke'};
    
    DEFAULT_ANSWERS = {'strtok', '#strtok', 'The one with strtok', ...
        'I like long walks on the strtok, strtokking in the woods, and just really a good strtok whenever I get the chance.', ...
        'One time I was walking down the hall and accidently spilled my strtok all over the floor', ...
        'There is no other function but strtok', 'Pro strtok', ...
        'One time I was teaching and almost forgot to strtok. So embarrassing.', ...
        'The only team. Jacob. JK strtok', ...
        '"To strtok, or not to strtok, that is the question. Wait that isn''t a question, always strtok"', ...
        'Remember to floss your strtok every day.', ...
        'there isn''t any strtok. So I add it myself.', ...
        '"Sugar pie honey strtok"', ...
        'I am an olympic strtoker. My strtoks are heard around the world.', ...
        'Any computer with a strtok.', ...
        'Why was I at bandcamp when I could have been strtoking.', ...
        'Astronaut. Just kidding, there are no strtoks in space.', ...
        'Make sure you include a strtok on every line.', ...
        'Why did the chicken cross the road? To get to the other strtok'};
    DEFAULT_FUN_FACTS = struct('question', DEFAULT_QUESTIONS, ...
        'answer', DEFAULT_ANSWERS);
% make sure help and fun match - if not, convert
[~, ~, helpdesk] = xlsread(help);
% format:
% * GT Username
% * Day
% * Start
% * Stop
%{
We don't actually have a way to convert to std at the moment; so just hope
it's in the correct format.
headers = helpdesk(1, :);
gtUser = strcmpi(headers, 'GT Username');
day = strcmpi(headers, 'Day');
start = strcmpi(headers, 'Start');
stop = strcmpi(headers, 'Stop');

helpdesk = raw;
%}

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
% convert into struct
headers = raw(1, :);
gtUser = strcmpi(headers, 'GT Username');
questions = strcmpi(headers, 'Question');
answers = strcmpi(headers, 'Answer');
funFacts = struct('gtUsername', raw(2:end, gtUser), ...
    'question', raw(2:end, questions), ...
    'answer', raw(2:end, answers));

[~, ~, basicInfo] = xlsread(basic);
[~, ~, sectionsInfo] = xlsread(sections);

% Error correction - anything that is NaN needs to die

% Create TA array
headers = basicInfo(1, :);
gtUser = basicInfo(2:end, strcmpi(headers, 'GT Username'));
name = basicInfo(2:end, strcmpi(headers, 'Name'));
major = basicInfo(2:end, strcmpi(headers, 'Major'));
title = basicInfo(2:end, strcmpi(headers, 'Title'));
title(cellfun(@isnumeric, title)) = {''};

tas = struct('gtUsername', gtUser, 'name', name, 'major', major, 'title', title, 'section', [], 'funFacts', {{}}, 'helpDesk', []);

% Decode sections
headers = sectionsInfo(1, :);
secNames = sectionsInfo(2:end, strcmpi(headers, 'name'));
secLocs = sectionsInfo(2:end, strcmpi(headers, 'location'));
secTimes = sectionsInfo(2:end, strcmpi(headers, 'time'));
firstUser = sectionsInfo(2:end, strcmpi(headers, 'first TA'));
secondUser = sectionsInfo(2:end, strcmpi(headers, 'second TA'));

mask = cellfun(@isnumeric, secNames);
secNames(mask) = cellfun(@num2str, secNames(mask), 'uni', false);
secData = struct('name', secNames, 'location', secLocs, 'time', secTimes);

emptySection = struct('name', '', 'location', '', 'time', '');

for t = 1:numel(tas)
    % find in first user or second user
    mask = strcmpi(tas(t).gtUsername, firstUser) | ...
        strcmpi(tas(t).gtUsername, secondUser);
    if any(mask)
        tas(t).section = secData(mask);
    else
        tas(t).section = emptySection;
    end
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
helpdesk(cellfun(@isempty, gtUser)) = [];
helpdesk(cellfun(@isnumeric, gtUser)) = [];
helpdesk(strcmp(gtUser, '#N/A')) = [];
% For each TA, collect all the helpdesk hours. Then, combine as necessary
for t = 1:numel(tas)
    tmp = helpdesk(strcmpi({helpdesk.gtUsername}, tas(t).gtUsername));
    % now, combine
    % if have the same day, AND start time of one = stop time of other (or vv), engage
    for i = numel(tmp):-1:1
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
    for i = 1:numel(tmp)
        tmp(i).time = [tmp(i).start ' - ' tmp(i).stop];
    end
    tmp = rmfield(tmp, 'start');
    tmp = rmfield(tmp, 'stop');
    tmp = rmfield(tmp, 'gtUsername');
    % decode day
    % inner for loop is inefficient; but again, as stated above, not a huge
    % deal.
    for d = 1:numel(tmp)
        switch lower(tmp(d).day)
            case {'m', 'monday', 'mon'}
                tmp(d).day = 'monday';
            case {'t', 'tues', 'tue', 'tuesday'}
                tmp(d).day = 'tuesday';
            case {'w', 'wed', 'wednesday'}
                tmp(d).day = 'wednesday';
            case {'r', 'thu', 'thurs', 'thur', 'thursday'}
                tmp(d).day = 'thursday';
            case {'f', 'fri', 'friday'}
                tmp(d).day = 'friday';
                % not necessary
            case {'s', 'sat', 'saturday'}
                tmp(d).day = 'saturday';
            case {'n', 'sun', 'sunday'}
                tmp(d).day = 'sunday';
            otherwise
                % wot
                % just leave...?
        end
    end
    tas(t).helpDesk = tmp;
end
% Decode fun facts.
%
% NOTE. existing fun facts might already exist! If extra JSON file provided, read from them and parse as necessary.
% if we already have fun facts, insert them into TAs. Then iterate through.
% inefficient, but given the time sensitivity (once a semester), the impact is low.
% Readability is better with this!
%
% load fun facts
if nargin > 4
    oldFunFacts = jsondecode(fileread(previous));
    % load
    for t = 1:numel(tas)
        % if exist, add!
        mask = strcmpi({oldFunFacts.gtUsername}, tas(t).gtUsername);
        if any(mask)
            tas(t).funFacts = oldFunFacts(mask).funFacts;
        end
    end
end

% Now, add new fun facts according to rules:
% 1. If submitted answers, and existing empty, just one-to-one assignment
% 2. If submitted answers, and existing NOT empty:
%   a. Any questions identical to ones submitted should have answers replaced
%   b. All other submitted questions appended
%   c. Any submitted questions that exist in original AND say `DELETE`, remove
% 3. If no submission, and existing NOT empty, unchanged
% 4. If no submission, and existing empty, assign default (strtok)
for t = 1:numel(tas)
    % get all answers
    currFunFacts = funFacts(strcmpi({funFacts.gtUsername}, tas(t).gtUsername));
    % follow order:
    if ~isempty(currFunFacts) && isempty(tas(t).funFacts)
        tas(t).funFacts = rmfield(currFunFacts, 'gtUsername');
    elseif ~isempty(currFunFacts) && ~isempty(tas(t).funFacts)
        % find identical
        for f = numel(currFunFacts):-1:1
            % if any in existing, replace and delete myself
            mask = strcmpi(currFunFacts(f).question, {tas(t).funFacts.question});
            if any(mask) && strcmpi(currFunFacts(f).answer, 'DELETE')
                tas(t).funFacts(mask) = [];
                currFunFacts(f) = [];
            elseif any(mask)
                tas(t).funFacts(mask).answer = currFunFacts(f).answer;
                currFunFacts(f) = [];
            end
        end
        % append new answers
        tas(t).funFacts((end+1):(end+numel(currFunFacts))) = rmfield(currFunFacts, 'gtUsername');
    elseif isempty(currFunFacts) && isempty(tas(t).funFacts)
        % assign default
        tas(t).funFacts = DEFAULT_FUN_FACTS;
    end
end
% Order alphabetically, then put STAS in the front
[~, inds] = sort({tas.name});
tas = tas(inds);
% It should go:
%   0. Instructor(s)
%   1. Head TA
%   2. CM
%   3. HW Team
%   4. Test Team
%   5. Software Dev
soft = strcmpi({tas.title}, 'Software Dev STA');
tas = [tas(soft); tas(~soft)];

test = strcmpi({tas.title}, 'Test Team STA');
tas = [tas(test); tas(~test)];

hw = strcmpi({tas.title}, 'Homework Team STA');
tas = [tas(hw); tas(~hw)];

cm = strcmpi({tas.title}, 'Course Manager');
tas = [tas(cm); tas(~cm)];

head = strcmpi({tas.title}, 'Head TA');
tas = [tas(head); tas(~head)];

others = strcmpi({tas.title}, 'Instructor') & ...
    ~(strcmpi({tas.gtUsername}, 'krogers34') | ...
    (strcmpi({tas.gtUsername}, 'ds182')));
tas = [tas(others); tas(~others)];

rogers = strcmpi({tas.gtUsername}, 'krogers34');
tas = [tas(rogers); tas(~rogers)];

smith = strcmpi({tas.gtUsername}, 'ds182');
tas = [tas(smith); tas(~smith)];
% create teachers.json (unless requested)
if nargout == 0
    json = unicode2native(jsonencode(tas), 'UTF-8');
    fid = fopen('teachers.json', 'wt', 'native', 'UTF-8');
    fwrite(fid, json, 'uint8');
    fclose(fid);
    clear json;
else
    json = tas;
end

end

function answers = fun2standard(raw)
% look for "GT Username". Every one after that is a question
gtUser = strcmpi(raw(1, :), 'GT Username');
% delete everything before
ind = find(gtUser);
gtUser = lower(raw(2:end, ind));
raw(:, 1:ind) = [];

% every column is now a question!
questions = raw(1, :);
raw(1, :) = [];
% for each TA, collate all answers and add to struct?
% for each GT Username, we add a row. So the max number is #q * #gtusername
answers = cell(1 + (numel(questions) * numel(gtUser)), 3);
answers(1, :) = {'GT Username', 'Question', 'Answer'};
counter = 2;
for g = 1:numel(gtUser)
    % go through each answer. If not empty, add!
    for a = 1:numel(questions)
        % if raw is NOT empty, engage
        if ~isempty(raw{g, a}) && ~any(isnan(raw{g, a}))
            answers(counter, :) = [gtUser(g), questions(a), raw(g, a)];
            counter = counter + 1;
        end
    end
end
answers(counter:end, :) = [];
end
