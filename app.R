# app.R
library(plumber)
library(readr)
library(dplyr)
library(ggraph)
library(tidygraph)
library(igraph)
library(ragg)
library(ggrepel)

#* @post /generate_network
#* @serializer contentType list(type = "image/png")
function(req, res) {
  temp_file <- tempfile(fileext = ".tsv")
  writeBin(req$postBody, temp_file)

  # Read TSV file
  df <- read_tsv(temp_file, show_col_types = FALSE)

  required_cols <- c("from", "to", "Type")
  if (!all(required_cols %in% colnames(df))) {
    res$status <- 400
    return(list(error = "Input TSV must contain columns: from, to, Type"))
  }

  # Convert to igraph and compute layout
  ig <- graph_from_data_frame(df, directed = FALSE)
  layout <- layout_with_fr(ig, weights = E(ig)$weight)

  # Convert to tidygraph
  g <- as_tbl_graph(ig) %>%
    activate(nodes) %>%
    mutate(Type = if ("Type" %in% colnames(df)) df$Type[match(name, df$from)], 
           Type = replace_na(Type, "Unknown"))

  # Save plot directly to PNG
  tmp_png <- tempfile(fileext = ".png")
  agg_png(tmp_png, width = 2000, height = 1500, res = 300)

  ggraph(g, layout = layout) +
    geom_edge_fan(alpha = 0.5) +
    geom_node_point(aes(fill = Type), size = 5, colour = "black", shape = 21, alpha = 0.7) +
    geom_node_text(aes(label = name), repel = TRUE, size = 4) +
    theme_void() +
    theme(
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10)
    )

  dev.off()

  res$body <- readBin(tmp_png, "raw", n = file.info(tmp_png)$size)
  res
}

# Run API
pr() |> pr_run(host = "0.0.0.0", port = 8000)
