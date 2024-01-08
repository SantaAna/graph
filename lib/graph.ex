defmodule Graph do
  require Logger
  def dijkstra(graph, starting_node) when is_map_key(graph, starting_node) do
    rec_dijkstra(graph, starting_node, %{
      lctn: %{starting_node => 0},
      lcpn: %{},
      kn: MapSet.new(),
      vn: MapSet.new(),
      queue: Heap.new()
    })
  end

  def rec_dijkstra(graph, current_node, info) do
    info =
      Enum.reduce(Map.get(graph, current_node), info, fn {adj, cost}, info ->
        current_node_cost = Map.get(info.lctn, current_node) 
        alt_cost = cost + current_node_cost 

        updated_info =
          case Map.get(info.lctn, adj) && Map.get(info.lctn, adj) > alt_cost do
            nil ->
              info
              |> put_in([:lctn, adj], alt_cost)
              |> put_in([:lcpn, adj], current_node)
              |> Map.update!(:queue, & Heap.insert(&1, {alt_cost, adj})) 

            true ->
              info
              |> put_in([:lctn, adj], alt_cost)
              |> put_in([:lcpn, adj], current_node)
              |> Map.update!(:queue, & Heap.insert(&1, {alt_cost, adj})) 

            false ->
              info
          end

        Map.update!(updated_info, :kn, &MapSet.put(&1, adj))
      end)
      |> Map.update!(:vn, &MapSet.put(&1, current_node))

    unvisited_nodes = MapSet.difference(info.kn, info.vn) |> MapSet.to_list()

    if length(unvisited_nodes) > 0 do
      {{_, next_node}, queue} = Heap.pop_top!(info.queue)
      rec_dijkstra(graph, next_node, Map.put(info, :queue, queue))
    else
      info
    end
  end

  def new(nodes, edges, options) do
    opts = Keyword.merge([weighted: false, directed: false], options)

    case [opts[:weighted], opts[:directed]] do
      [false, false] ->
        Enum.reduce(nodes, %{}, fn node, graph ->
          node_neighbors =
            Enum.flat_map(edges, fn
              {node1, node2} when node1 == node -> [node2]
              {node1, node2} when node2 == node -> [node1]
              _ -> []
            end)

          Map.put_new(graph, node, node_neighbors)
        end)

      [true, false] ->
        Enum.reduce(nodes, %{}, fn node, graph ->
          node_neighbors =
            Enum.flat_map(edges, fn
              {node1, node2, weight} when node1 == node -> [{node2, weight}]
              {node1, node2, weight} when node2 == node -> [{node1, weight}]
              _ -> []
            end)

          Map.put_new(graph, node, node_neighbors)
        end)

      [false, true] ->
        Enum.reduce(nodes, %{}, fn node, graph ->
          node_neighbors =
            Enum.flat_map(edges, fn
              {node1, node2} when node1 == node -> [node2]
              _ -> []
            end)

          Map.put_new(graph, node, node_neighbors)
        end)

      [true, true] ->
        Enum.reduce(nodes, %{}, fn node, graph ->
          node_neighbors =
            Enum.flat_map(edges, fn
              {node1, node2, weight} when node1 == node -> [{node2, weight}]
              _ -> []
            end)

          Map.put_new(graph, node, node_neighbors)
        end)
    end
  end
end
