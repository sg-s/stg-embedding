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

colors('normal') = color.aqua('blue');


% nearly normal
colors('aberrant-spikes') = color.aqua('teal');
colors('irregular-bursting') = color.aqua('brown');
colors('irregular') = color.aqua('gray');


% LP fucked
colors('LP-weak-skipped') = color.aqua('pink'); 
colors('LP-silent-PD-bursting') = [1.0000    0.1034    0.7241];
colors('LP-silent') = color.aqua('orange');

% PD fucked
colors('PD-weak-skipped') = color.aqua('green');
colors('PD-silent') = color.aqua('lime');
colors('PD-silent-LP-bursting') = [0 144 81]/255;

colors('sparse-irregular') = color.aqua('indigo');



colors('silent') = [ 0 0 0 ];


%  [1.0000    0.8276   0];
% [0 144 81]/255;
% color.aqua('lime');




colors('LP') = color.aqua('red');
colors('PD') = color.aqua('indigo');
