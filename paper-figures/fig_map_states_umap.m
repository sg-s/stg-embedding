%% this figure makes the map and colors them, but uses uMAP instead of t-SNE for the embedding



conda activate umap
u = umap;
u.n_neighbors = 75; % was 50
u.repulsion_strength = 2;

R = u.fit(VectorizedData);

fig_map_states

clear R