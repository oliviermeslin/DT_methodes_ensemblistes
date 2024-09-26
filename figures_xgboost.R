library(xgboost)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(viridis)


############################################
# Generate data
############################################

data <- data.frame(
  x = runif(500, 0, 10)
) |>
  mutate(id = row_number()) |>
  mutate(
    target_clean = sin(x) + 0.02 * x^2 + 0.9 * cos((x - 1.5)^2/2.5),
    train = as.integer(runif(n()) > 0.2) 
  ) |>
  mutate(
    target_noisy = target_clean 
    + runif(n(), -2, 2) * (runif(n()) > 0.85) 
  ) |>
  pivot_longer(
    cols = c("target_clean", "target_noisy"),
    names_to = "target_type",
    values_to = "target_value"
  ) |>
  mutate(
    label_target = if_else(
      target_type == "target_clean", "Sans bruit", "Avec bruit"
    ) |> factor(levels = c("Sans bruit", "Avec bruit"), ordered = TRUE)
  )

############################################
# Train the models
############################################

train <- data |> filter(train == 1)
test  <- data |> filter(train == 0)

bstSparse_clean <- xgboost(
  data = train |> filter(target_type == "target_clean") |> select(x) |> as.matrix(), 
  label = train |> filter(target_type == "target_clean") |> pull(target_value), 
  max.depth = 2, eta = 1, 
  nthread = 2, nrounds = 20, objective = "reg:squarederror")

bstSparse_noisy <- xgboost(
  data = train |> filter(target_type == "target_noisy") |> select(x) |> as.matrix(), 
  label = train |> filter(target_type == "target_noisy") |> pull(target_value),
  max.depth = 2, eta = 1, 
  nthread = 2, nrounds = 20, objective = "reg:squarederror")

test2 <- test |>
  filter(target_type == "target_clean") |>
  mutate(
    pred_target_1_tree     = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
    pred_target_2_trees    = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
    pred_target_3_trees    = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
    pred_target_4_trees    = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
    pred_target_5_trees    = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
    pred_target_10_trees   = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
    pred_target_20_trees   = predict(bstSparse_clean, test |> filter(target_type == "target_clean") |> pull(x) |> as.matrix(), iterationrange = c(1, 1))
  ) |>
  bind_rows(
    test |>
      filter(target_type == "target_noisy") |>
      mutate(
        pred_target_1_tree     = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
        pred_target_2_trees    = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
        pred_target_3_trees    = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
        pred_target_4_trees    = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
        pred_target_5_trees    = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
        pred_target_10_trees   = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
        pred_target_20_trees   = predict(bstSparse_noisy, test |> filter(target_type == "target_noisy") |> pull(x) |> as.matrix(), iterationrange = c(1, 1))
      )
  ) |>
  pivot_longer(
    cols = starts_with("pred"),
    values_to = "prediction",
    names_to = "number_trees"
  ) |>
  mutate(number_trees = number_trees |> str_extract("\\d+") |> as.integer())


############################################
############################################
############################################
# Plot the results
############################################
############################################
############################################

############################################
# Plot the targets
############################################


# Clean target
ggplot(data |> filter(target_type == "target_clean")) + 
  geom_line(aes(x = x, y = target_value), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")

# Noisy target
ggplot(data |> filter(target_type == "target_noisy")) + 
  geom_line(aes(x = x, y = target_value), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")

############################################
# Plot the predictions (clean target)
############################################

test2 |> 
  filter(target_type == "target_clean" & number_trees %in% c(1, 5, 10, 20)) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction, color = factor(number_trees)), size = 0.5) +
  geom_line(aes(x = x, y = target_value), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prédiction", color = "Number of trees") +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


test2 |> 
  filter(target_type == "target_noisy" & number_trees %in% c(1, 5, 10, 20)) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction, color = factor(number_trees)), size = 0.5) +
  geom_line(aes(x = x, y = target_value), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prédiction", color = "Number of trees") +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")



ggplot(test2) + 
  geom_line(aes(x = x, y = pred_target_10_trees, color = label_target), size = 0.5) +
  labs(x = "x", y = "Prédiction", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")



ggplot(test2) + 
  geom_line(aes(x = x, y = pred_target_all_trees, color = label_target), size = 0.5) +
  labs(x = "x", y = "Prédiction", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")

ggplot(test2 |> filter(target_type == "target_clean")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_10_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "target_clean")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_all_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "target_noisy")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_10_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "target_noisy")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_all_trees), color = "black") +
  theme_minimal()




