function ind = find_bfs_nodes(A, start_ind, num_nodes)

ind = graphtraverse(sparse(A), start_ind, 'directed', false, 'method', 'bfs');
ind = ind(1:num_nodes);
end
