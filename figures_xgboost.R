library(xgboost)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(viridis)
library(ranger)

set.seed(321)

############################################
# Generate data
############################################

data <- data.frame(
  x = seq(0, 10, 10 / 500)
) |>
  mutate(id = row_number()) |>
  mutate(
    target_clean = sin(x) + 0.02 * x^2 + 0.5 * cos((x - 1.5)^2/2.5),
    train = as.integer(runif(n()) > 0.2) 
  ) |>
  mutate(
    target_noisy = target_clean 
    + runif(n(), -4, 4) * (runif(n()) > 0.9) 
  )

# Clean target
ggplot(data) + 
  geom_line(aes(x = x, y = target_clean), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")

# Noisy target
ggplot(data) + 
  geom_line(aes(x = x, y = target_noisy), size = 0.5) + 
  labs(x = "x", y = "Target", color = NULL) +
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")


############################################
# Train the models
############################################

max.depth <- 4

train <- data |> filter(train == 1)
test  <- data |> filter(train == 0)

model_xgb_clean <- xgboost(
  data = train  |> select(x) |> as.matrix(), 
  label = train |> pull(target_clean),
  max.depth = max.depth, eta = 1, 
  nthread = 2, nrounds = 50, objective = "reg:squarederror")

model_xgb_noisy <- xgboost(
  data = train  |> select(x) |> as.matrix(), 
  label = train |> pull(target_noisy),
  max.depth = max.depth, eta = 1, 
  nthread = 2, nrounds = 50, objective = "reg:squarederror")

model_rf_clean <- ranger(
  target_clean ~ ., data = train  |> select(target_clean, x), num.trees = 50, max.depth = max.depth, replace = TRUE, sample.fraction = 0.2
)

model_rf_noisy <- ranger(
  target_noisy ~ ., data = train  |> select(target_noisy, x), num.trees = 50, max.depth = max.depth, replace = TRUE, sample.fraction = 0.2
)


test2 <- test |>
  mutate(
    prediction_xgb_clean_1_tree     = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
    prediction_xgb_clean_2_trees    = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
    prediction_xgb_clean_3_trees    = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
    prediction_xgb_clean_4_trees    = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
    prediction_xgb_clean_5_trees    = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
    prediction_xgb_clean_10_trees   = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
    prediction_xgb_clean_20_trees   = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 21)),
    prediction_xgb_clean_50_trees   = predict(model_xgb_clean, test |> pull(x) |> as.matrix(), iterationrange = c(1, 1)),
    prediction_xgb_noisy_1_tree     = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 2)),
    prediction_xgb_noisy_2_trees    = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 3)),
    prediction_xgb_noisy_3_trees    = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 4)),
    prediction_xgb_noisy_4_trees    = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 5)),
    prediction_xgb_noisy_5_trees    = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 6)),
    prediction_xgb_noisy_10_trees   = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 11)),
    prediction_xgb_noisy_20_trees   = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 21)),
    prediction_xgb_noisy_50_trees   = predict(model_xgb_noisy, test |> pull(x) |> as.matrix(), iterationrange = c(1, 1)),
    
    
    prediction_rf_clean_1_tree     = predict(model_rf_clean, data = test |> select(x), num.trees =  1)$predictions,
    prediction_rf_clean_2_trees    = predict(model_rf_clean, data = test |> select(x), num.trees =  2)$predictions,
    prediction_rf_clean_3_trees    = predict(model_rf_clean, data = test |> select(x), num.trees =  3)$predictions,
    prediction_rf_clean_4_trees    = predict(model_rf_clean, data = test |> select(x), num.trees =  4)$predictions,
    prediction_rf_clean_5_trees    = predict(model_rf_clean, data = test |> select(x), num.trees =  5)$predictions,
    prediction_rf_clean_10_trees   = predict(model_rf_clean, data = test |> select(x), num.trees = 10)$predictions,
    prediction_rf_clean_20_trees   = predict(model_rf_clean, data = test |> select(x), num.trees = 20)$predictions,
    prediction_rf_clean_50_trees   = predict(model_rf_clean, data = test |> select(x), num.trees = 50)$predictions,
    prediction_rf_noisy_1_tree     = predict(model_rf_noisy, data = test |> select(x), num.trees =  1)$predictions,
    prediction_rf_noisy_2_trees    = predict(model_rf_noisy, data = test |> select(x), num.trees =  2)$predictions,
    prediction_rf_noisy_3_trees    = predict(model_rf_noisy, data = test |> select(x), num.trees =  3)$predictions,
    prediction_rf_noisy_4_trees    = predict(model_rf_noisy, data = test |> select(x), num.trees =  4)$predictions,
    prediction_rf_noisy_5_trees    = predict(model_rf_noisy, data = test |> select(x), num.trees =  5)$predictions,
    prediction_rf_noisy_10_trees   = predict(model_rf_noisy, data = test |> select(x), num.trees = 10)$predictions,
    prediction_rf_noisy_20_trees   = predict(model_rf_noisy, data = test |> select(x), num.trees = 20)$predictions,
    prediction_rf_noisy_50_trees   = predict(model_rf_noisy, data = test |> select(x), num.trees = 50)$predictions
    
  ) |>
  pivot_longer(
    cols = starts_with("pred"),
    values_to = "prediction",
    names_to = "prediction_name"
  ) |>
  mutate(
    model_type   = prediction_name |> str_extract("(xgb|rf)"),
    number_trees = prediction_name |> str_extract("\\d+") |> as.integer(),
    target_type  = prediction_name |> str_extract("(noisy|clean)")
  ) |>
  mutate(
    label_target = if_else(target_type == "clean", "Clean data", "Noisy data") |> 
      factor(levels = c("Clean data", "Noisy data"), ordered = TRUE),
    label_model = if_else(model_type == "xgb", "Boosting", "Random forest") |> 
      factor(levels = c("Boosting", "Random forest"), ordered = TRUE)
  )


############################################
############################################
############################################
# Plots
############################################
############################################
############################################

############################################
# Plot the target
############################################

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


############################################
############################################
# Plot the predictions
############################################
############################################

selection <- c(1, 2, 5, 10)

############################################
# Random forest
############################################

# Random forest model trained on the clean target
test2 |> 
  filter(label_model == "Random forest" & label_target == "Clean data" & number_trees %in% selection) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


# Random forest model trained on the noisy target
test2 |> 
  filter(label_model == "Random forest" & label_target == "Noisy data" & number_trees %in% selection) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


############################################
# Boosting
############################################

# Boosting model trained on the clean target
test2 |> 
  filter(label_model == "Boosting" & label_target == "Clean data" & number_trees %in% selection) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


# Boosting model trained on the noisy target
test2 |> 
  filter(label_model == "Boosting" & label_target == "Noisy data" & number_trees %in% selection) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


############################################
# Comparison boosting versus random forest
############################################


# Boosting model and RF model trained on the clean target
test2 |> 
  filter(label_target == "Clean data" & number_trees == 50) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction, color = label_model), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")


# Boosting model and RF model trained on the noisy target
test2 |> 
  filter(label_target == "Noisy data" & number_trees == 50) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction, color = label_model), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  scale_color_viridis_d(end = 0.7) + 
  theme_minimal() +
  theme(legend.position = "bottom")


# Boosting model trained on the noisy target
test2 |> 
  filter(label_model == "Boosting" & label_target == "Noisy data" & number_trees %in% selection) |>
  ggplot() + 
  geom_line(aes(x = x, y = prediction), size = 0.5) +
  geom_line(aes(x = x, y = target_clean), size = 0.5, color = "red", linetype = "dashed") +
  labs(x = "x", y = "Prediction", color = "Type of target") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  facet_wrap("number_trees")


