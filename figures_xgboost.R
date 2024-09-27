library(xgboost)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(viridis)
library(ranger)


############################################
# Generate data
############################################

data <- data.frame(
  x = seq(0, 10, 10 / 200)
) |>
  mutate(id = row_number()) |>
  mutate(
    target_clean = sin(x) + 0.02 * x^2 + 0.5 * cos((x - 1.5)^2/2.5),
    train = as.integer(runif(n()) > 0.2) 
  ) |>
  mutate(
    target_noisy = target_clean 
    + runif(n(), -3, 3) * (runif(n()) > 0.9) 
  )

# Clean target
ggplot(data) + 
  geom_line(aes(x = x, y = target_clean), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")


############################################
# Train the models
############################################

train <- data |> filter(train == 1)
test  <- data |> filter(train == 0)

bstSparse_clean <- xgboost(
  data = train  |> select(x) |> as.matrix(), 
  label = train |> pull(target_clean),
  max.depth = 2, eta = 1, 
  nthread = 2, nrounds = 50, objective = "reg:squarederror")

bstSparse_noisy <- xgboost(
  data = train  |> select(x) |> as.matrix(), 
  label = train |> pull(target_noisy),
  max.depth = 2, eta = 1, 
  nthread = 2, nrounds = 50, objective = "reg:squarederror")

test2 <- test |>
  mutate(
    pred_target_clean_1_tree     = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
    pred_target_clean_2_trees    = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
    pred_target_clean_3_trees    = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
    pred_target_clean_4_trees    = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
    pred_target_clean_5_trees    = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
    pred_target_clean_10_trees   = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
    pred_target_clean_20_trees   = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 21)),
    pred_target_clean_50_trees   = predict(bstSparse_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 1)),
    pred_target_noisy_1_tree     = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
    pred_target_noisy_2_trees    = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
    pred_target_noisy_3_trees    = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
    pred_target_noisy_4_trees    = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
    pred_target_noisy_5_trees    = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
    pred_target_noisy_10_trees   = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
    pred_target_noisy_20_trees   = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 21)),
    pred_target_noisy_50_trees   = predict(bstSparse_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 1))
  ) |>
  pivot_longer(
    cols = starts_with("pred"),
    values_to = "prediction",
    names_to = "prediction_name"
  ) |>
  mutate(
    number_trees = prediction_name |> str_extract("\\d+") |> as.integer(),
    target_type  = prediction_name |> str_extract("(noisy|clean)") |> stringr::str_to_title()
  ) |>
  mutate(
    label_target = if_else(
      target_type == "clean", "Sans bruit", "Avec bruit"
    ) |> factor(levels = c("Sans bruit", "Avec bruit"), ordered = TRUE)
  )


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
data |>
  pivot_longer(
    cols = c("target_clean", "target_noisy"),
    names_to = "target_type",
    values_to = "target_value"
  ) |>
  mutate(
    label_target = if_else(target_type == "target_clean", "Clean", "Noisy") |> factor(levels = c("Clean", "Noisy"), ordered = TRUE)
  ) |>
  ggplot() + 
  geom_line(aes(x = x, y = target_value), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("label_target")

# Noisy target
ggplot(data) + 
  geom_line(aes(x = x, y = target_noisy), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")

############################################
# Plot the predictions (clean target)
############################################

test2 |> 
  filter(target_type == "Clean" & number_trees %in% c(2, 5, 10, 20)) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


test2 |> 
  filter(target_type == "Noisy" & number_trees %in% c(2, 5, 10, 20)) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")

test2 |> 
  filter(number_trees %in% c(2, 5, 10, 20)) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction, color = target_type), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
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

ggplot(test2 |> filter(target_type == "clean")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_10_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "clean")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_all_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "noisy")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_10_trees), color = "black") +
  theme_minimal()

ggplot(test2 |> filter(target_type == "noisy")) + 
  geom_line(aes(x = x, y = target_value), color = "gray50") +
  geom_line(aes(x = x, y = pred_target_all_trees), color = "black") +
  theme_minimal()




