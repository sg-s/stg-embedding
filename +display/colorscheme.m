% defines a universal colorscheme
% for the categories
% the returned object is a dictionary object

function colors = colorscheme(cats)


if iscategorical(cats)
	cats = categories(cats);
end

% make a colorscheme

C = colormaps.dcol(length(cats));

colors = dictionary;
for i = 1:length(cats)
    colors.(cats(i)) = C(i,:);
end

colors('regular') = color.aqua('blue');


% nearly normal
colors('aberrant-spikes') = color.aqua('teal');
colors('irregular-bursting') = color.aqua('brown');
colors('irregular') = color.aqua('gray');


% LP fucked
colors('LP-weak-skipped') = [255 150 138]/255;
colors('LP-silent-PD-bursting') = color.aqua('pink'); 
colors('LP-silent') = color.aqua('orange');

% PD fucked
colors('PD-weak-skipped') = color.aqua('green');
colors('PD-silent') = color.aqua('lime');
colors('PD-silent-LP-bursting') = [0 144 81]/255;

colors('sparse-irregular') = color.aqua('indigo');

colors('silent') = [ 0 0 0 ];



colors('LP') = color.aqua('red');
colors('PD') = color.aqua('indigo');
