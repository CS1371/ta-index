%% updateIndex: Update the TA index
%
% Update the TA Index via an excel sheet that represents possible changes.
%
% updateIndex() will interactively ask for the existing JSON file, as well
% as the excel sheet, to effect the changes and create a new effective
% JSON.
%
% updateIndex(J, E) will use JSON path J and Excel path E to automatically
% generate the new excel sheet.
%
%%% Remarks
%
% The new JSON will be created in the same folder as the original JSON.
%
% The change Excel sheet should have the following format:
%   Sheet: teachers
%       - GT Username
%       - Name
%       - Section
%       - Major
%       - Title
%       - Delete*
%   Sheet: sections
%       - Section
%       - Location
%       - Time
%   Sheet: questions
%       - GT Username
%       - <Question1>
%       - <Answer1>
%       - <Question2>
%       - <Answer2>
%       - ...
%   Sheet: helpdesk
%       This sheet is identical to that of the original Help Desk sheet.
%
% *Delete is an optional column. If present, and cell that has content in
% that column means the associated TA should be deleted.
%
% Note: There could be more columns, but at least these columns must be
% present AND have this header.
%
function updateIndex(json, changes)
    GT_USER = 'GT Username';
    GT_USER_COL = 1;
    NAME = 'Name';
    NAME_COL = 2;
    SECTION = 'Section';
    SECTION_COL = 3;
    MAJOR = 'Major';
    MAJOR_COL = 4;
    TITLE = 'Title';
    TITLE_COL = 5;
    DELETE = 'Delete';
    DELETE_COL = 6;
    LOC_COL = 2;
    TIME_COL = 3;
    
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
    
    DEFAULT_ANSWERS = cellfun(@httpencode, {'strtok', '#strtok', 'The one with strtok', ...
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
        'Why did the chicken cross the road? To get to the other strtok'}, 'uni', false);
    
    if nargin == 0
        % ask for both JSON and change set
        [name, path] = uigetfile('*.json (JSON)', 'JSON file');
        if islogical(name)
            return;
        else
            json = [path name];
        end
        
        [name, path] = uigetfile('*.xlsx (Excel)', 'Change file');
        if islogical(name)
            return;
        else
            changes = [path name];
        end
    end
    
    % decode original
    fid = fopen(json, 'rt');
    teachers = char(fread(fid)');
    fclose(fid);
    teachers = jsondecode(teachers);
    
    % read change set
    [~, ~, users] = xlsread(changes, 'teachers');
    [~, ~, sections] = xlsread(changes, 'sections');
    [~, ~, questions] = xlsread(changes, 'questions');
    [~, ~, helpdesk] = xlsread(changes, 'helpdesk');
    
    mask = cellfun(@(s)(any(isnan(s))), users(:, 1));
    users(mask, :) = [];
    mask = cellfun(@(s)(any(isnan(s))), sections(:, 1));
    sections(mask, :) = [];
    mask = cellfun(@(s)(any(isnan(s))), questions(:, 1));
    questions(mask, :) = [];
    mask = cellfun(@isnumeric, sections(:, 1));
    sections(mask, 1) = cellfun(@num2str, sections(mask, 1), 'uni', false);
    % Standardize
    % users:
    %       - GT Username
    %       - Name
    %       - Section
    %       - Major
    %       - Title
    %       - Delete*
    
    tmp = cell(size(users, 1), 6);
    headers = users(1, :);
    tmp(:, GT_USER_COL) = users(:, strcmpi(headers, GT_USER));
    tmp(:, NAME_COL) = users(:, strcmpi(headers, NAME));
    tmp(:, SECTION_COL) = users(:, strcmpi(headers, SECTION));
    tmp(:, MAJOR_COL) = users(:, strcmpi(headers, MAJOR));
    tmp(:, TITLE_COL) = users(:, strcmpi(headers, TITLE));
    
    mask = cellfun(@(s)(any(isnan(s))), tmp(:, SECTION_COL));
    tmp(mask, SECTION_COL) = {''};
    
    mask = cellfun(@isnumeric, tmp(:, SECTION_COL));
    tmp(mask, SECTION_COL) = cellfun(@num2str, tmp(mask, SECTION_COL), 'uni', false);
    
    % if no delete, make it all false
    if ~any(strcmpi(headers, DELETE))
        tmp(:, DELETE_COL) = {false};
    else
        tmp(:, DELETE_COL) = ...
            cellfun(@(c)(~isempty(c)), ...
            users(:, strcmpi(headers, DELETE)), 'uni', false);
    end
    users = tmp;
    
    % for each record, act appropriately
    helpdesks = convertHelpdesk(helpdesk);
    for r = 2:size(users, 1)
        if any(strcmpi({teachers.gtUsername}, users{r, 1}))
            ind = strcmpi({teachers.gtUsername}, users{r, 1});
        else
            % new teacher
            teachers(end+1) = struct('gtUsername', users{r, GT_USER_COL}, ...
                'name', users{r, NAME_COL}, ...
                'major', users{r, MAJOR_COL}, ...
                'section', [], 'helpDesk', [], 'title', users{r, TITLE_COL}, ...
                'funFacts', []);
            ind = numel(teachers);
        end
        
        teacher = teachers(ind);
        
        teacher.name = httpencode(users{r, NAME_COL});
        if ~isempty(users{r, MAJOR_COL}) && ~any(isnan(users{r, MAJOR_COL}))
            teacher.major = httpencode(users{r, MAJOR_COL});
        end
        if any(isnan(users{r, TITLE_COL})) || isempty(users{r, TITLE_COL})
            teacher.title = '';
        else
            teacher.title = httpencode(users{r, TITLE_COL});
        end
        
        
        % Section
        mask = strcmpi(sections(:, 1), users{r, SECTION_COL});
        section = struct('section', httpencode(users{r, SECTION_COL}), ...
            'location', httpencode(sections{mask, LOC_COL}), ...
            'time', httpencode(sections{mask, TIME_COL}));
        teacher.section = section;
        % Fun Facts
        mask = strcmpi(questions(:, 1), teacher.gtUsername);
        % if not found, default
        quests = questions(1, 2:end);
        if any(mask)
            answers = cellfun(@httpencode, questions(mask, 2:end), 'uni' ,false);
            % if teacher has no questions, just make struct
            if isempty(teacher.funFacts)
                mask = cellfun(@(a)(isempty(a) || any(isnan(a))), answers);
                funs = struct('question', quests(~mask), 'answer', answers(~mask));
            else
                % remove all questions that are identical: question is
                % same, answer is same
                for q = numel(quests):-1:1
                    if isempty(answers{q}) || any(isnan(answers{q}))
                        quests(q) = [];
                        answers(q) = [];
                    else
                        mask = strcmp({teacher.funFacts.question}, quests{q});
                        if any(mask)
                            % check if answer is the same
                            if ~strcmp(teacher.funFacts(mask).answer, answers{q})
                                teacher.funFacts(mask).answer = httpencode(answers{q});
                            end
                            quests(q) = [];
                            answers(q) = [];
                        end
                    end
                end
                funs = [teacher.funFacts' struct('question', quests, 'answer', answers)];
            end
            teacher.funFacts = funs;
        else
            % if teachers have no questions, no change
            if isempty(teacher.funFacts)
                % assign default
                teacher.funFacts = struct('question', DEFAULT_QUESTIONS, ...
                    'answer', DEFAULT_ANSWERS);
            end
        end
        
        % Help Desk
        % look up name in help desks. If found, assign; otherwise, empty
        mask = strcmpi({helpdesks.name}, teacher.name);
        if any(mask)
            teacher.helpDesk = rmfield(helpdesks(mask), 'name');
        else
            teacher.helpDesk = [];
        end
        teachers(ind) = teacher;
    end
    for t = numel(teachers):-1:1
        if ~any(strcmp(teachers(t).gtUsername, users(2:end, GT_USER_COL)))
            teachers(t) = [];
        end
    end
    [path, name, ~] = fileparts(json);
    if isempty(path)
        path = pwd;
    end
    fid = fopen([path filesep name '_new.json'], 'wt');
    json = unicode2native(jsonencode(teachers), 'UTF-8');
    fwrite(fid, json, 'uint8');
    fclose(fid);
end

% helpdesk will be struct, where each entry has:
%   name
%   day
%   time
function helpdesk = convertHelpdesk(raw)
    % iterate through each row.
    helpdesk = struct('name', cell(1, numel(raw)), ...
        'day', cell(1, numel(raw)), 'time', cell(1, numel(raw)));
    % no real way to figure out how many help desks we have
    r = 1;
    counter = 1;
    while r <= size(raw, 1)
        switch lower(raw{r, 1})
            case 'monday'
                day = 'monday';
            case 'tuesday'
                day = 'tuesday';
            case 'wednesday'
                day = 'wednesday';
            case 'thursday'
                day = 'thursday';
            case 'friday'
                day = 'friday';
            otherwise
                day = '';
        end
        % if day isn't empty, then 1 row below is TIME, TA 1, ...
        % 2 rows below is start of time
        if ~isempty(day)
        
            % We don't know how many TAs we have for this row, but it doesn't
            % really matter. Just keep iterating to the right; if NaN, skip
            r = r + 2;
            % r points to first time row.
            
            % keep moving until NaN or empty
            while r <= size(raw, 1) && ~any(isnan(raw{r, 1})) && ~isempty(raw{r, 1})
                % iterate across row, assigning DAY and TIME
                time = raw{r, 1};
                for t = 2:size(raw, 2)
                    if ~any(isnan(raw{r, t})) && ~isempty(raw{r, t})
                        helpdesk(counter).day = day;
                        helpdesk(counter).time = time;
                        helpdesk(counter).name = raw{r, t};
                        counter = counter + 1;
                    end
                end
                r = r + 1;
            end

        end
        
        r = r + 1;
    end
    helpdesk(counter:end) = [];
    
    [~, inds] = sort({helpdesk.name});
    helpdesk = helpdesk(inds);
    % Time Chaining
    % If a TA helps from 3-4 and 4-5, they are really just helping 3-5. We
    % need to reflect this!
    %
    % So, for each TA, reduce it to minimum amount.
    %
    % For each helpdesk (specific TA), look through remaining help desks
    % (for that TA). If any are consecutive, combine, delete, and continue.
    
    names = unique({helpdesk.name});
    tmp = helpdesk;
    counter = 1;
    for n = 1:numel(names)
        name = names{n};
        helps = helpdesk(strcmp({helpdesk.name}, name));
        
        h = 1;
        while h <= numel(helps)
            % search for consecutive
            [start, stop] = time2num(helps(h).time);
            
            for i = numel(helps):-1:(h+1)
                [posStart, posStop] = time2num(helps(i).time);
                if strcmp(helps(i).day, helps(h).day)
                    % three possible cases:
                    %   1. first stop == second start. In this case, change
                    %   h to be [first start - second stop].
                    %   2. second stop == first start. In this case, change
                    %   h to be [second start - first stop].
                    %   3. stop ~= start and vv. Do nothing
                    %
                    % in cases 2 and 3, delete i and recalculate start,
                    % stop.
                    if stop == posStart
                        stop = posStop;
                        helps(i) = [];
                    elseif start == posStop
                        start = posStart;
                        helps(i) = [];
                    end
                    helps(h).time = sprintf('%d PM - %d PM', start, stop);
                    [start, stop] = time2num(helps(h).time);
                end
            end
            h = h + 1;
        end
        tmp(counter:(counter + numel(helps) - 1)) = helps;
        counter = counter + numel(helps);
    end
    tmp(counter:end) = [];
    helpdesk = tmp;
end

function [start, stop] = time2num(time)
    start = time(1:strfind(time, '-'));
    start = str2double(start(start < '9' & start > '0'));
    stop = time(strfind(time, '-'):end);
    stop = str2double(stop(stop < '9' & stop > '0'));
end

function str = httpencode(str)
    if nargin == 0 || isempty(str) || any(isnan(str))
        str = '';
    else
        str = strrep(strrep(strrep(str, '&', '&amp;'), '''', '&#34;'), '"', '&#39;');
    end
end