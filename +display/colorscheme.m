function colors = colorscheme(cats)


% make a colorscheme

C = colormaps.dcol(length(cats));

colors = dictionary;
for i = 1:length(cats)
    colors.(cats(i)) = C(i,:);
end

colors('normal') = color.aqua('blue');
colors('LP-01') = color.aqua('brown');
colors('PD-01') = color.aqua('green');
colors('sparse-irregular') = color.aqua('indigo');
colors('LP-silent-PD-bursting') = color.aqua('orange');
colors('LP-silent') = color.aqua('pink');
