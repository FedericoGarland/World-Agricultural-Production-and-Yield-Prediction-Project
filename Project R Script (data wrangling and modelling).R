# WORLD AGRICULTURAL PRODUCTION PROJECT - DATA ANALYTICS
library(tidyverse)
library(readxl)
library(ggplot2)
library(caret)
library(leaps)
library(MASS)
library(ggcorrplot)
library(psych)
library(broom)
library(car)
library(lmtest)
library(gvlma)
library(lm.beta)

# DATA WRANGLING
# STRUCTURING IRRIGATION DATA
irrigation <- as.data.frame(read_excel("C:/Users/User/Documents/Data/Proyecto 1/irrigation_raw.xlsx", sheet = 1))
irrigation
str(irrigation)


irrigation_countries <- list()
countries <- c()
for(i in 1:nrow(irrigation)){
  irrigation_countries[[i]] <- as.vector(as.numeric(irrigation[i,]))
  countries[i] <- irrigation[i, 1]
}
names(irrigation_countries) <- countries
irrigation_countries

country_means <- sapply(irrigation_countries, mean, na.rm = TRUE)
country_means

clean_irrigation <- data.frame(Country = irrigation[,"Country Name"],
                               Avg_Irrigated_Area = unname(country_means))
clean_irrigation

write.table(clean_irrigation, file = "C:/Users/User/Documents/Data/Proyecto 1/irrigation_clean.csv", sep = ";", row.names = FALSE)


# STRUCTURING TRACTOR DATA ---- 
tractor <- as.data.frame(read_excel("C:/Users/User/Documents/Data/Proyecto 1/tractor_raw.xlsx", sheet = 1))
head(tractor)

tractor_countries <- list()
countries <- c()
for(i in 1:nrow(tractor)){
  tractor_countries[[i]] <- as.vector(as.numeric(tractor[i,]))
  countries[i] <- tractor[i,1]
}
names(tractor_countries) <- countries
tractor_countries

country_tractor_means <- sapply(tractor_countries, mean, na.rm = TRUE)
country_tractor_means

clean_tractor <- data.frame(Country = tractor[,"Country"], 
                            avg_tractor = unname(country_tractor_means))
clean_tractor

write.table(clean_tractor, file = "C:/Users/User/Documents/Data/Proyecto 1/tractor_clean.csv", sep = ";", row.names = FALSE)

# ---- ALL CROP AVERAGE YIELD PREDICTION ------------
# MANUALLY FITTING MULTIPLE LINEAR REGRESSION MODEL
# Loading data 
data <- read_excel("C:/Users/User/Documents/Data/Proyecto 1/proyecto1_R.xlsx", sheet = 1)
data <- as.data.frame(data)
head(data)

# Subsetting
train <- na.omit(data[,-1]) # Removing country column from training set 

# Exploratory analysis 
psych::describe(train)

corr_matrix <- round(cor(train), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 2.3)


# Fitting Model 1 (Full model)
model1 <- lm(Yield ~ ., train)
summary(model1) # R2 = 0.50, Residual Standard Error (RSE) = 10.66, p > 0.05 (non-significant/ns)

# Checking for multicollinearity for Model 1 through VIF (Variance Inflation Factor)
vif <- vif(model1)
vif

#create horizontal bar chart to display each VIF value
vif <- vif[order(vif, decreasing = FALSE)] # ordering variables according to increasing VIF
barplot(vif, main = "VIF Values", horiz = TRUE, col = "steelblue", las = 2, cex.names = 0.7) # Creating graph
abline(v = 10, lwd = 3, lty = 2) # Adding line at the VIF = 20 mark

# Fitting Model 2 without variables with Model 1 VIF > 20
model2 <- lm(Yield ~ Temperature + Rainfall + Avg_irrigated_area + Rate_pesticides + Total_pesticides
             + Avg_tractor_density + Avg_fertilized_area_k + Avg_gross_rate_n + Avg_gross_rate_k
             + Min_temperature + Max_temperature, train)
summary(model2) # R2 = 0.27, RSE = 12.93, p > 0.05 (ns) - Model 2 performs worse than Model 1

# Checking for multicollinearity for Model 2
vif <- vif(model2)
vif

# Fitting Model 3 without variables with Model 1 VIF > 10 
model3 <- lm(Yield ~ Temperature + Rate_pesticides + Total_pesticides + Max_temperature, train)
summary(model3) # R2 = 0.22, RSE = 13.37, p < 0.05 (significant/*) - Model 3 performs worse than Models 1 and 2 but is significant

vif <- vif(model3)
vif

# Fitting Model 4 with variables having r > 0.25 with yield in correlation matrix 
model4 <- lm(Yield ~ Avg_tractor_density + Avg_fertilized_area_n + Avg_fertilized_area_p + Avg_fertilized_area_k 
             + Avg_rate_n + Rate_pesticides + Avg_total_p + Max_temperature + Min_temperature + Temperature, train)
summary(model4) # R2 = 0.17, RSE = 13.8, p > 0.05 (ns) - Model 4 performs the worst of all models

# Checking for multicollinearity for Model 4
vif <- vif(model4)
vif

# Fitting Model 5 without variables with Model 4 VIF > 10
model5 <- lm(Yield ~ Avg_tractor_density + Avg_fertilized_area_k + Avg_rate_n + Rate_pesticides
             + Avg_total_p + Max_temperature + Min_temperature + Temperature, train)
summary(model5) # R2 = 0.23, RSE = 13.26, p > 0.05 (ns) - Model 5 performs better than Model 4 but is non-significant

# USING STEPWISE REGRESSION FUNCTION 
# Fit full model 
full.model <- lm(Yield ~., train)

# Stepwise regression model
step.model <- stepAIC(full.model, direction = "both", 
                      trace = FALSE)
summary(step.model) # R2 = 0.71, RSE = 8.1, p < 0.0001 (***), best model so far

# Checking for multicollinearity in stepwise regression model (step.model)
vif(step.model)

# Fitting step.model2 by removing non-significant variables from step.model
step.model2 <- lm(Yield ~ Avg_irrigated_area + Rate_pesticides + Avg_total_p +
                    Avg_total_k + Avg_rate_n + Avg_fertilized_area_k + Avg_gross_rate_p + 
                    Max_temperature, train)
summary(step.model2) # R2 = 0.64, RSE = 9.04, p < 0.0001 (***), performs slightly worse than step.model 

#Checking for multicollinearity step.model2
vif(step.model2)

# Fitting step.model3 by removing non-significant variables from step.model2
step.model3 <- lm(Yield ~ Rate_pesticides + Avg_rate_n + Avg_fertilized_area_k + Avg_gross_rate_p + Max_temperature, train)
summary(step.model3) # R2 = 0.60, RSE = 9.58, p < 0.0001 (***), best model yet since all predictors are significant (p < 0.05)

# Checking for multicollinearity step.model3
vif(step.model3)

# Residual Analysis (Assumption checking) ---- 
# Model diagnostic metrics
model.diag.metrics <- augment(step.model3)
model.diag.metrics

# Residual independence (Durbin-Watson test)
durbin <- durbinWatsonTest(step.model3)
durbin$p #p > 0.05 - Residuals are independent

# Normality (Shapiro-Wilk test)
shapiro.test(model.diag.metrics$.resid) # p < 0.05, residuals are NOT normally distributed

# Homoscedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(step.model3) # Original: p < 0.05, homoscedasticity of residuals is NOT fulfilled
lmtest::bptest(step.model3) # Studentized: p > 0.05, homoscedasticity of residuals is fulfilled
# Final decision will be made according to Scale-Location graph 

# General 
gvlma(step.model3)

# Graphic assumption checking (Residual plots)
autoplot(step.model3) 

# Interpretation 
# PLOT 1 Residuals vs Fitted -- Line is considerably skewed, thus it can be infered that linearity assumption is NOT fulfilled
# PLOT 2 Normal QQ Plot - Many points fall away from the line and Shapiro-Wilk has p-value < 0.05, thus it can be infered normality of residuals assumption is NOT fulfilled
# PLOT 3 Scale-Location - Line is considerably skewed, in combination with the results of the original Breusch-Pagan test and near significant results (p = 0.07) of the studentized version, it can be infered that homoscedasticity assumption is NOT fulfilled
# PLOT 4 Residualds vs Leverage - Data point 43 is an outlier (standardized residual > 3), but no points outside of Cook's distance treshold (therefore no influential values) 


# Solutions: 
# Non-Linearity -> Transform independent variables (through log, square root, square, etc.)
# Non-normality -> Box-Cox or log transformation of predictors that have high non-normal distribution
# Heteroskedasticity -> Transform dependent variable (Yield)


# Fitting step.model4 applying logarithmic transformation to Max_temperature
step.model4 <- lm(Yield ~ Rate_pesticides + Avg_rate_n + Avg_fertilized_area_k + Avg_gross_rate_p + log(Max_temperature), train)
summary(step.model4) # R2 = 0.60, RSE = 9.55, p < 0.0001 (***) - Best model so far, slightly improved linearity in plot 1
autoplot(step.model4)


# Fitting step.model5 applying square root transformation to Rate_pesticides
step.model5 <- lm(Yield ~ sqrt(Rate_pesticides) + Avg_rate_n + Avg_fertilized_area_k + Avg_gross_rate_p + log(Max_temperature), train)
summary(step.model5) # R2 = 0.60, RSE = 9.54, p < 0.0001 (***) - Best model so far, slightly improved linearity and normality
autoplot(step.model5)

# Fitting step.model6 applying square exponent to Avg_fertilized_area_k
step.model6 <- lm(Yield ~ sqrt(Rate_pesticides) + Avg_rate_n + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(step.model6) # R2 = 0.62, RSE = 9.34, p < 0.0001 (***) - Best model so far
autoplot(step.model6)

# Fitting step.model7 applying log transformation to yield to correct heteroskedasticity
step.model7 <- lm(log(Yield) ~ sqrt(Rate_pesticides) + Avg_rate_n + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(step.model7) # R2 = 0.72, RSE = 0.36 (log) and 1.44 (original units), p < 0.0001 (***) - Best model so far
autoplot(step.model7) # Linearity and homoscedasticity have improved, but normality seems to have worsened

# Finding predictors with high skewness and significant non-normality
psych::describe(train[,c("Rate_pesticides", "Avg_rate_n", "Avg_fertilized_area_k", "Avg_gross_rate_p", "Max_temperature")])
shapiro.test(train[,"Avg_rate_n"]) # Avg_rate_n is not normally distributed and has high skewness
shapiro.test(train[,"Avg_gross_rate_p"]) #Avg_gross_rate_p is not normally distributed and has high skewness

# Applying Box Cox transformation on Avg_rate_n
#Avg_rate_n data
Avg_rate_n <- train[,"Avg_rate_n"]

#Box Cox transformation
bc<-boxcox(lm(Avg_rate_n ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba is -0.06060606
Avg_rate_n_BC <- (Avg_rate_n^L-1)/ L

# Assessing normality and skewness
# Box Cox results
shapiro.test(Avg_rate_n_BC) # p > 0.05, transformed variable is normal
psych::describe(Avg_rate_n_BC) # skew = 0

# Log results
shapiro.test(log(Avg_rate_n)) # p < 0.05, log transformed variable is not normal
skew(log(Avg_rate_n)) # skew = 0.11, slightly skewed

# DECISION 1 -> Build model using Box Cox transformed results

# Training set with Box-Cox results from Avg_rate_n
train <- cbind(train, Avg_rate_n_BC)

# Applying Box Cox and Log transformation on Avg_gross_rate_p and assessing normality
#Avg_gross_rate_p data
Avg_gross_rate_p <- train[,"Avg_gross_rate_p"]

#Box Cox transformation
bc<-boxcox(lm(Avg_gross_rate_p ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is 0.3838384
Avg_gross_rate_p_BC <- (Avg_gross_rate_p^L-1)/ L

# Assessing normality and skewness 
# Box Cox results
shapiro.test(Avg_gross_rate_p_BC) # p < 0.05, Box Cox transformed variable is not normal
skew(Avg_gross_rate_p_BC) # skew = 0.23, slightly skewed

# Log results
shapiro.test(log(Avg_gross_rate_p)) # p < 0.05, log transformed variable is not normal
psych::describe(log(Avg_gross_rate_p)) # skew = -1.73, highly skewed

# DECISION 2 -> Not build model with transformed Avg_gross_rate_p results

# Fitting step.model8 using Box-Cox transformed Avg_rate_n
step.model8 <- lm(log(Yield) ~ sqrt(Rate_pesticides) + Avg_rate_n_BC + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(step.model8) # R2 = 0.76, RSE = 0.34 (log) and 1.40 (original units), p < 0.0001 (***) - Best model so far
autoplot(step.model8) # Normality has improved as has linearity, but heteroskedasticity seems to have worsened

# RESIDUAL ANALYSIS step.model8 ---
# Statistical assumption checking  
# Model diagnostic metrics
model.diag.metrics <- augment(step.model8)
model.diag.metrics$.resid <- model.diag.metrics$`log(Yield)` - model.diag.metrics$.fitted

# Residual independence (Durbin-Watson test)
durbinWatsonTest(step.model8) #p > 0.05 - Residuals are independent

# Normality (Shapiro-Wilk test)
shapiro.test(model.diag.metrics$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(step.model8) # p > 0.05, residuals present homoscedasticity
lmtest::bptest(step.model8) # p > 0.05, residuals present homoscedasticity

# General 
gvlma(step.model8) # All asumptions are acceptable

# Fitting alternative model with Box-Cox transformed yield 
Yield <- train$Yield

bc<-boxcox(lm(Yield ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is -0.1818182
Yield_BC <- (Yield^L-1)/ L


shapiro.test(Yield)
shapiro.test(Yield_BC)
shapiro.test(log(Yield))

train <- cbind(train, Yield_BC)

alt.model <- lm(Yield_BC ~ sqrt(Rate_pesticides) + Avg_rate_n_BC + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(alt.model) # R2 = 0.76, RSE = 0.206 (Box-Cox) and 1.23 (original units), p < 0.0001 (***) - Best model


# RESIDUAL ANALYSIS alt.model --- 
# Statistical assumption checking 
# Model diagnostic metrics
model.diag.metrics <- augment(alt.model)
model.diag.metrics$.resid <- model.diag.metrics$Yield_BC - model.diag.metrics$.fitted

# Residual independence (Durbin-Watson test)
durbinWatsonTest(alt.model) #p > 0.05 - Residuals are independent

# Normality (Shapiro-Wilk test)
shapiro.test(model.diag.metrics$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(alt.model) # p > 0.05, residuals present homoscedasticity
lmtest::bptest(alt.model) # p > 0.05, residuals present homoscedasticity

# General 
gvlma(alt.model) # All asumptions are acceptable

# Graphic assumption checking (Residual plots)
autoplot(alt.model)

# Formula for returning Box-Cox transformed Yield to original units
Yield_original <- exp(log(L * Yield_BC + 1) /L)
Yield_original


# Fitting second alternative model 2 using log transformed yield and log transformed Avg_rate_n
alt.model2 <- lm(log(Yield) ~ sqrt(Rate_pesticides) + log(Avg_rate_n) + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(alt.model2) # R2 = 0.76, RSE = 0.337 (log) and 1.4 (original units), p < 0.0001 (***) - Best model

# RESIDUAL ANALYSIS alt.model --- 
# Statistical assumption checking 
# Model diagnostic metrics
model.diag.metrics <- augment(alt.model2)
model.diag.metrics$.resid <- log(train$Yield) - model.diag.metrics$.fitted

# Residual independence (Durbin-Watson test)
durbinWatsonTest(alt.model2) #p > 0.05 - Residuals are independent

# Normality (Shapiro-Wilk test)
shapiro.test(model.diag.metrics$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(alt.model2) # p > 0.05, residuals present homoscedasticity
lmtest::bptest(alt.model2) # p > 0.05, residuals present homoscedasticity

# General 
gvlma(alt.model2) # All asumptions are acceptable

# Graphic assumption checking (Residual plots)
autoplot(alt.model2)


# FINAL MODEL - Final model is alt.model2 because it is simpler than alt.model using only log transform instead of Box Cox for both the response and predictor Avg_rate_n
final.allcrop.model <- lm(log(Yield) ~ sqrt(Rate_pesticides) + log(Avg_rate_n) + I(Avg_fertilized_area_k^{2}) + Avg_gross_rate_p + log(Max_temperature), train)
summary(final.allcrop.model) # R2 = 0.76, RSE = 0.337 (log) and 1.4 (original units), p < 0.0001 (***)

# Obtain unstandardized and standardized coefficients
# Unstandardized
final.allcrop.model$coefficients
sort(as.vector(abs(final.allcrop.model$coefficients)), decreasing = TRUE)

# Standardized
std.coef <- lm.beta(final.allcrop.model) 

rank.coef <- data.frame(Predictor = names(std.coef$coefficients), 
                        Standardized_coefficient = unname(std.coef$standardized.coefficients))
rank.coef
arrange(rank.coef, -abs(Standardized_coefficient))

# Final goodness of fit graph
final.model.diag.metrics <- augment(final.allcrop.model)
measured <- log(train$Yield)
predicted <- final.model.diag.metrics$.fitted
datos_gráfica <- as.data.frame(cbind(Measured = measured, Predicted = predicted))

ggplot(datos_gráfica, aes(Measured, Predicted)) + 
  geom_point(aes(col = "Predicted"), size = 2) + 
  geom_smooth(method = "lm", se = FALSE, aes(col = "Model line")) + 
  geom_line(data = datos_gráfica, aes(Measured, Measured, col = "Real line")) + 
  labs(x = "Measured values", y = "Predicted values") +
  coord_cartesian(xlim = c(min(measured), 1.1*max(predicted)), ylim = c(min(predicted), 1.1*max(predicted))) +
  scale_color_manual(name= "Legend",
                     breaks=c("Real line", "Model line", "Predicted"),
                     values=c("Real line" = "black", "Model line" = "blue" , "Predicted"= "red")) +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 0),
                                                  shape = c(NULL, NULL, 20),
                                                  size = c(1, 1, 2)))) +
  ggtitle(label = "Goodness of fit of all-crop average yield prediction model") +
  theme(legend.title= element_text(size= 15),
        legend.text= element_text(size= 13),
        legend.position = c(0.85, 0.2),
        legend.background = element_rect(fill="lightblue", 
                                         size=0.5, linetype="solid",
                                         colour ="black"), 
        legend.key = element_rect(fill = "lightblue"),
        axis.line.y = element_line(),
        axis.line.x = element_line(), 
        panel.border = element_rect(colour = "black", fill = NA), 
        plot.title = element_text(hjust = 0.5, size = 18), 
        axis.text.y = element_text(size = 13, angle = 90, hjust = 0.5),
        axis.text.x = element_text(size = 13),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15))




# CROP SPECIFIC YIELD PREDICTION -----------
# MAIZE YIELD PREDICTION  ---- 
data <- read_excel("C:/Users/User/Documents/Data/Proyecto 1/proyecto1_R.xlsx", sheet = 2)
data <- as.data.frame(data)
head(data)

# Subsetting
train <- na.omit(data[,-c(1, 2)])
head(train)
psych::describe(train)
nrow(train)
length(train)

corr_matrix <- round(cor(train), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 2.3)


# Fitting Full model
full.model <- lm(Yield ~ ., train)
summary(full.model) # Cannot be computed due to 0 degrees of freedom (number of predictors is equal to number of observations)


colnames(train)

# Fitting model 2 with predictors having r > 0.1 (this excludes Min_temperature and Rainfall)
model2 <- lm(Yield ~ Temperature + Avg_irrigated_area + 
               Rate_pesticides + Total_pesticides + Avg_tractor_density +
               Avg_total_n + Avg_total_p + Avg_total_k + Avg_total_compound + 
               Avg_rate_n + Avg_rate_p + Avg_rate_k + Avg_fertilized_area_n + 
               Avg_fertilized_area_p + Avg_fertilized_area_k + Avg_gross_rate_n + 
               Avg_gross_rate_p + Avg_gross_rate_k + Avg_gross_rate_compound + Max_temperature, train)
summary(model2) # R2 = 0.38, RSE = 1.75, p > 0.05 (ns) 

# Using stepwise regression with model 2 as the full model 
step.model <- stepAIC(model2, direction = "both", 
                      trace = FALSE)
summary(step.model) # R2 = 0.79, RSE = 1.02, p < 0.05 (*)

# Checking for multicollinearity in model 2
vif(model2)

# Fitting model 3 without variables with VIF > 20 
model3 <- lm(Yield ~ Temperature + Rate_pesticides + Avg_tractor_density + Avg_rate_k 
             + Avg_gross_rate_p + Max_temperature, train)
summary(model3) # R2 = 0.65, RSE = 1.3, p < 0.05 (*) - Performs better than model 2

# Fitting model 4 without non-significant variables 
model4 <- lm(Yield ~ Temperature + Avg_tractor_density, train)
summary(model4) # R2 = 0.60, RSE = 1.4, p < 0.0001 (***) - Performs worse than model 3 but is significant

# Fitting model 5 re-adding variables having r > 0.6
model5 <- lm(Yield ~ Temperature + Avg_tractor_density + Avg_rate_n + Avg_rate_p, train)
summary(model5) # R2 = 0.85, RSE = 0.87, p < 0.0001 (***) - Performs better than model 4 

# Checking for multicollinearity in model 5
vif(model5)

# Fitting model 6 eliminating non-significant variables from model 5
model6 <- lm(Yield ~ Temperature + Avg_tractor_density + Avg_rate_n, train)
summary(model6) # R2 = 0.85, RSE = 0.85, p < 0.0001 (***) - Best model so far

# Checking for multicollinearity in model 6 
vif(model6)

# RESIDUAL ANALYSIS model6 --- 
# Statistical assumption checking
# Model diagnostic metrics 
diag <- augment(model6)

# Residual independence (Durbin-Watson test)
durbinWatsonTest(model6) #p < 0.05 - Residuals are NOT independent

# Normality (Shapiro-Wilk test)
shapiro.test(diag$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model6) # p > 0.05, residuals present homoscedasticity
lmtest::bptest(model6) # p > 0.05, residuals present homoscedasticity

# General 
gvlma(model6) 

# Residual plots (Graphical assumption checking)
autoplot(model6)

# Interpretation 
# PLOT 1 Residuals vs Fitted -- Line is slightly skewed, it can be infered that linearity is not fulfilled
# PLOT 2 Normal QQ Plot - Many points fall away from the line even though Shapiro-Wilk has p-value > 0.05, thus it is preferable to infer that normality of residuals assumption is not fulfilled
# PLOT 3 Scale-Location - Line is considerably skewed, even thought Breusch-Pagan test concludes there is no heteroskedasticity, it is preferable to assume that homoscedasticity is not fulfilled
# PLOT 4 Residualds vs Leverage - No outliers and no points outside of Cook's distance treshold (therefore no influential values) 


# Solutions: 
# Non-independence (autocorrelation) -> Transform independent variables or add more variables that correlate with the residuals
# Non-linearity -> Transform independent variables (through log, square root, square, etc.)
# Non-normality -> Box-Cox or log transformation of predictors that have high non-normal distribution
# Heteroskedasticity -> Transform dependent variable (Yield)


# Finding other independent variables that correlate with the residuals of model6
independence_checking <- cbind(train, diag$.resid)
corr_matrix <- round(cor(independence_checking), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 2.3) # Total_pesticides is the variable with highest correlation to residuals

# Fitting model 7 using Total_pesticides
model7 <- lm(Yield ~ Temperature + Avg_tractor_density + Avg_rate_n + Total_pesticides, train)
summary(model7) # R2 = 0.87, RSE = 0.79, p < 0.0001 (***) - Best model so far, though Total_pesticides is not significant under 0.05 significant level, but it is marginally significant under 0.06 significance level

# Checking for independence
durbinWatsonTest(model7) # p > 0.05, the inclusion of Total_pesticides in the model has resolved the problem of non-independence

# Checking for rest of assumptions
diag7 <- augment(model7)

# Normality
shapiro.test(diag7$.resid) # p < 0.05, residuals are not normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model7) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model7) # p > 0.05, residuals are homoscedastic

# Residual plots
autoplot(model7) # Line is slightly skewed, linearity can me improved

gvlma(model7)


# Fitting model 8 transforming dependent variable 
model8 <- lm(sqrt(Yield) ~ Temperature + Avg_tractor_density + Avg_rate_n + Total_pesticides, train)
summary(model8) # R2 = 0.84, RSE = 0.226 (sqrt) and 0.05 (original units), p < 0.0001 (***) - Best model so far, Total_pesticides has become significant with this model

# Checking assumptions
diag8 <- augment(model8)
diag8$.resid <- sqrt(train$Yield) - diag8$.fitted

# Normality
shapiro.test(diag8$.resid) # p < 0.05, residuals are not normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model8) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model8) # p > 0.05, residuals are homoscedastic

# Residual plots
autoplot(model8) # Linearity has considerable improved

gvlma(model8) # Linearity assumption

# Finding predictors with high skewness and non-normality
predictors <- train[,c("Temperature", "Avg_tractor_density", "Avg_rate_n")]
psych::describe(predictors)
apply(predictors, 2, shapiro.test) #Avg_tractor_density and Avg_rate_n are not normally distributed
boxplot(scale(predictors), col = "orange")

# Applying Box Cox and Log transformation on Avg_tractor_density and assessing normality
#Avg_gross_rate_p data
Avg_tractor_density <- train[,"Avg_tractor_density"]

#Box Cox transformation
bc<-boxcox(lm(Avg_tractor_density ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is -0.1010101
Avg_tractor_density_BC <- (Avg_tractor_density^L-1)/ L

# Assessing normality and skewness 
# Box Cox results
shapiro.test(Avg_tractor_density_BC) # p > 0.05, Box Cox transformed variable is normally distributed
skew(Avg_tractor_density_BC) # skew = 0.04, not skewed

# Log results
shapiro.test(log(Avg_tractor_density)) # p > 0.05, log transformed variable is normally distributed
skew(log(Avg_tractor_density)) # skew = 0.22, slightly skewed

# DECISION: Build model using Box-Cox transformed Avg_tractor_density

# Applying Box Cox and Log transformation on Avg_rate_n and assessing normality
#Avg_gross_rate_p data
Avg_rate_n <- train[,"Avg_rate_n"]

#Box Cox transformation
bc<-boxcox(lm(Avg_rate_n ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is 0.1818182
Avg_rate_n_BC <- (Avg_rate_n^L-1)/ L

# Assessing normality and skewness 
# Box Cox results
shapiro.test(Avg_rate_n_BC) # p > 0.05, Box Cox transformed variable is normally distributed
skew(Avg_rate_n_BC) # skew = -0.02, not skewed

# Log results
shapiro.test(log(Avg_rate_n)) # p > 0.05, log transformed variable is normally distributed
skew(log(Avg_rate_n)) # skew = -0.22, slightly skewed

# DECISION: Build model using Box-Cox transformed Avg_rate_n

train <- cbind(train, Avg_rate_n_BC)

# Fitting model 9 using Box-Cox transformed Avg_rate_n
model9 <- lm(sqrt(Yield) ~ Temperature + Avg_tractor_density + Avg_rate_n_BC + Total_pesticides, train)
summary(model9) # R2 = 0.85, RSE = 0.22 (sqrt) and 0.048 (original units), p < 0.0001 (***) - Best model so far

# Assumption checking
diag9 <- augment(model9)

# Independence
durbinWatsonTest(model9) # p > 0.05, residuals are independent

# Normality
shapiro.test(diag9$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model9) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model9) # p > 0.05, residuals are homoscedastic

# Residual plots
autoplot(model9) 

# General
gvlma(model9) # All assumptions are acceptable


# Fitting model 10 using log transformed Avg_rate_n
model10 <- lm(sqrt(Yield) ~ Temperature + Avg_tractor_density + log(Avg_rate_n) + Total_pesticides, train)
summary(model10) # R2 = 0.85, RSE = 0.22 (sqrt) and 0.05 (original units), p < 0.0001 (***) - Best model so far, log transformation of Avg_rate_n is less complex than Box-Cox transformation

# Assumption checking
diag10 <- augment(model10)

# Independence
durbinWatsonTest(model10) # p > 0.05. residuals are independent

# Normality
shapiro.test(diag10$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model10) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model10) # p > 0.05, residuals are homoscedastic

# Residual plots
autoplot(model10) 

# General
gvlma(model10) # All assumptions are acceptable

# Alternative model
# Applying Box Cox and Log transformation on Yield and assessing normality
#Yield data 
Yield <- train[,"Yield"]

#Box Cox transformation
bc<-boxcox(lm(Yield ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is 0.6262626
Yield_BC <- (Yield^L-1)/ L

alt.train <- cbind(train, Yield_BC)

# Fitting alternative model with Box-Cox transformed Yield 
alt.model <- lm(Yield_BC ~ Temperature + Avg_tractor_density + log(Avg_rate_n) + Total_pesticides, alt.train)
summary(alt.model) # R2 = 0.85, RSE = 0.52 (Box-Cox) and 1.57 (original units), p < 0.0001 (***) - Performs equally well than model 10 but adds complexity, so the alternative model can be discarded


# FINAL MODEL (Model 10)
final.maize.model <- lm(sqrt(Yield) ~ Temperature + Avg_tractor_density + log(Avg_rate_n) + Total_pesticides, train)
summary(final.maize.model) # R2 = 0.85, RSE = 0.22 (sqrt) and 0.05 (original units), p < 0.0001 (***)

# Obtain unstandardized and standardized coefficients
# Unstandardized
final.maize.model$coefficients
sort(as.vector(abs(final.maize.model$coefficients)), decreasing = TRUE)

# Standardized
std.coef <- lm.beta(final.maize.model) 

rank.coef <- data.frame(Predictor = names(std.coef$coefficients), 
                        Standardized_coefficient = unname(std.coef$standardized.coefficients))
rank.coef
arrange(rank.coef, -abs(Standardized_coefficient))

# Final goodness of fit graph
diag <- augment(final.maize.model)
measured <- sqrt(train$Yield)
predicted <- diag$.fitted
datos_gráfica <- as.data.frame(cbind(Measured = measured, Predicted = predicted))

ggplot(datos_gráfica, aes(Measured, Predicted)) + 
  geom_point(aes(col = "Predicted"), size = 2) + 
  geom_smooth(method = "lm", se = FALSE, aes(col = "Model line")) + 
  geom_line(data = datos_gráfica, aes(Measured, Measured, col = "Real line")) + 
  labs(x = "Measured values", y = "Predicted values") +
  coord_cartesian(xlim = c(min(measured), 1.01*max(predicted)), ylim = c(min(measured), 1.01*max(predicted))) +
  scale_color_manual(name= "Legend",
                     breaks=c("Real line", "Model line", "Predicted"),
                     values=c("Real line" = "black", "Model line" = "blue" , "Predicted"= "red")) +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 0),
                                                  shape = c(NULL, NULL, 20),
                                                  size = c(1, 1, 2)))) +
  ggtitle(label = "Goodness of fit of maize yield prediction model") +
  theme(legend.title= element_text(size= 15),
        legend.text= element_text(size= 13),
        legend.position = c(0.85, 0.2),
        legend.background = element_rect(fill="lightblue", 
                                         size=0.5, linetype="solid",
                                         colour ="black"), 
        legend.key = element_rect(fill = "lightblue"),
        axis.line.y = element_line(),
        axis.line.x = element_line(), 
        panel.border = element_rect(colour = "black", fill = NA), 
        plot.title = element_text(hjust = 0.5, size = 18), 
        axis.text.y = element_text(size = 13, angle = 90, hjust = 0.5),
        axis.text.x = element_text(size = 13),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15))



# WHEAT YIELD PREDICTION ---- 
data <- read_excel("C:/Users/User/Documents/Data/Proyecto 1/proyecto1_R.xlsx", sheet = 3)
data <- as.data.frame(data)
head(data)

# Subsetting 
train <- na.omit(data[,-c(1, 2)])
train

# Exploratory analysis 
psych::describe(train)

corr_matrix <- round(cor(train), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 2.3)

# Fitting model1 (full model)
model1 <- lm(Yield ~ ., train)
summary(model1) # R2 = 0.77, RSE = 0.8, p < 0.01 (**) - Many predictors are not significant

# Checking for multicollinearity for Model 1 through VIF (Variance Inflation Factor)
vif <- vif(model1)
vif

#create horizontal bar chart to display each VIF value
vif <- vif[order(vif, decreasing = FALSE)] # ordering variables according to increasing VIF
barplot(vif, main = "VIF Values", horiz = TRUE, col = "steelblue", las = 2, cex.names = 0.7) # Creating graph
abline(v = 10, lwd = 3, lty = 2) # Adding line at the VIF = 20 mark

# Fitting Model 2 without variables with Model 1 VIF > 20
model2 <- lm(Yield ~ Temperature + Rainfall + Avg_irrigated_area + Rate_pesticides + Total_pesticides + Avg_tractor_density
             + Avg_rate_n + Avg_rate_k + Avg_fertilized_area_k + Avg_gross_rate_p + Avg_gross_rate_k + Min_temperature 
             + Max_temperature, train) 
summary(model2) # R2 = 0.68, RSE = 0.98, p < 0.001 (**) - Many predictors are still not significant

# Fitting model 3 using variables with r > 0.2 with Yield in correlation matrix 
model3 <- lm(Yield ~ Rate_pesticides + Avg_tractor_density + Avg_rate_n + Avg_fertilized_area_k + 
               Avg_rate_k + Avg_gross_rate_k + Avg_gross_rate_n + Avg_gross_rate_compound +
               Total_pesticides + Temperature + Max_temperature + Avg_irrigated_area, train)
summary(model3) # R2 = 0.66, RSE = 1.01, p < 0.001 (**) - Many predictors still not significant

# Multicollinearity model 3
vif(model3)

# Fitting model 4 without variables having VIF > 5
model4 <- lm(Yield ~ Rate_pesticides + Avg_tractor_density + Avg_rate_n + Avg_fertilized_area_k 
             + Avg_rate_k + Total_pesticides + Temperature + Max_temperature + Avg_irrigated_area, train)
summary(model4) # R2 = 0.63, RSE = 1.04, p < 0.001 (**) - Many predictors still not significant 

# Multicollinearity model 4
vif(model4)

# Stepwise regression model
step.model <- stepAIC(model1, direction = "both", 
                      trace = FALSE)
summary(step.model) # R2 = 0.86, RSE = 0.65, p < 0.0001 (***) - Best model so far, but not all predictors are significant

# Checking for multicollinearity in step.model
vif(step.model)

# Fitting model 5 without variables with VIF > 10 from step.model
model5 <- lm(Yield ~ Rate_pesticides + Total_pesticides + Avg_tractor_density + Avg_rate_n 
             + Avg_fertilized_area_k + Avg_gross_rate_n + Avg_gross_rate_p + Avg_gross_rate_k 
             + Min_temperature + Max_temperature, train)
summary(model5)

# Fitting model 6 without non-significant variables from model 5
model6 <- lm(Yield ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + Avg_gross_rate_k, train)
summary(model6) # R2 = 0.73, RSE = 0.76, p < 0.0001 (***) - All predictors significant

# Fitting model 7 adding to model 6 the significant variables from step.model that also have VIF < 10
model7 <- lm(Yield ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + Avg_gross_rate_k 
             + Rate_pesticides + Total_pesticides + Min_temperature + Max_temperature, train)
summary(model7) # R2 = 0.76, RSE = 0.83, p < 0.0001 (***) - Not all predictors are significant 

# Fitting model 8 without non-significant variables from model 7 
model8 <- lm(Yield ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + Avg_gross_rate_k 
             + Rate_pesticides, train)
summary(model8) # R2 = 0.77, RSE = 0.83, p < 0.0001 (***) - Best model so far, all predictors significant

# RESIDUAL ANALYSIS (Assumption checking)
# Model diagnostic metrics 
diag <- augment(model8)

# Independence
durbinWatsonTest(model8) # p > 0.05, residuals are independent 

# Normality
shapiro.test(diag$.resid) # p > 0.05, residuals are normally distributed

# Homocedasticity (Breusch-Pagan test, original and studentized)
car::ncvTest(model8) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model8) # p > 0.05, residuals are homoscedastic

# General 
gvlma(model8) # Linearity is not satisfied 

# Residual plots
autoplot(model8)

# Interpretation 
# PLOT 1 Residuals vs Fitted -- Line is considerably skewed, linearity not fulfilled
# PLOT 2 Normal QQ Plot - Some points fall away from the line even though Shapiro-Wilk has p-value > 0.05, it can be infered that normality is fulfilled but still it could be improved
# PLOT 3 Scale-Location - Line is not skewed, and Breusch-Pagan test concludes there is no heteroskedasticity, it can be infered that homoscedasticity is fulfilled
# PLOT 4 Residuals vs Leverage - No outliers and no points outside of Cook's distance treshold (therefore no influential values) 


# Solutions: 
# Non-linearity -> Transform independent variables (through log, square root, square, etc.)
# Non-normality -> Box-Cox or log transformation of predictors that have high non-normal distribution


# Finding predictors with high skewness and non-normality 
predictors <- train[,c("Avg_rate_n", "Avg_gross_rate_n", "Avg_gross_rate_p", "Avg_gross_rate_k", "Rate_pesticides")]
psych::describe(predictors) # Avg_gross_rate_p, Avg_gross_rate_k and Rate_pesticides have high skewness
apply(predictors, 2, shapiro.test) # The three previously mentioned predictors are not normally distributed (p < 0.05)

# Fitting model 9 with squared Avg_gross_rate_k (transforming the other 2 predictors was tested and failed to correct non-linearity)
model9 <- lm(Yield ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + I(Avg_gross_rate_k^2)
             + Rate_pesticides, train)
summary(model9) # R2 = 0.76, RSE = 0.84, p < 0.0001 (***) 

# Checking if linearity assumption is fulfilled
gvlma(model9) # Linearity is fulfilled statistically, but Link Function assumption is not satisfied (this suggests yield should be treated as a categorical variable)
autoplot(model9) # The line still seems to be considerably skewed 

# Fitting model 10 with log transformed
model10 <- lm(log(Yield) ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + I(Avg_gross_rate_k^2), train)
summary(model10) # R2 = 0.76, RSE = 0.24 (log) and 1.28 (original units), p < 0.0001 (***) - Model has slightly worsened but satisfies linearity assumption


# Residual Analysis 
diag10 <- augment(model10)
diag10$.resid <- log(train$Yield) - diag10$.fitted

# Independence
durbinWatsonTest(model10) # p > 0.05, residuals are independent

# Normality 
shapiro.test(diag10$.resid) # p > 0.05, residuals are normally distributed 

# Homoscedasticity 
car::ncvTest(model10) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model10) # p > 0.05, residuals are homoscedastic

# General
gvlma(model10) # All assumptions are satisfied

# Residual plots
autoplot(model10) # Linearity has improved considerably, with the line decreasing it's skewness 

autoplot(model10)
# Alternative model applying Box Cox transformation
Rate_pesticides <- train[,"Rate_pesticides"]
Avg_gross_rate_p <- train[,"Avg_gross_rate_p"]
Yield <- train[,"Yield"]

#Box Cox transforming all 3 predictors
# Rate_pesticides
bc<-boxcox(lm(Rate_pesticides ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is 0.4242424
Rate_pesticides_BC <- (Rate_pesticides^L-1)/ L

# Avg_gross_rate_p 
bc<-boxcox(lm(Avg_gross_rate_p ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is -0.2626263
Avg_gross_rate_p_BC <- (Avg_gross_rate_p^L-1)/ L

# Yield
bc<-boxcox(lm(Yield ~ 1), lambda=seq(-2,2,l=100))
L<-with(bc,x[which.max(y)]);L	# Lamba value is -0.4242424
Yield_BC <- (Yield^L-1)/ L


# Creating new train dataset
alt.train <- cbind(train, Avg_gross_rate_p_BC, Rate_pesticides, Yield_BC)

# Alternative model using Box-Cox transformed Rate_pesticides and original unit Yield 
alt.model <- lm(Yield ~ Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + I(Avg_gross_rate_k^{2})
                + Rate_pesticides_BC, alt.train)
summary(alt.model) # R2 = 0.77, RSE = 0.82, p < 0.0001 (***)


# Residual Analysis 
diag.alt <- augment(alt.model)

# Independence
durbinWatsonTest(alt.model) # p > 0.05, residuals are independent

# Normality 
shapiro.test(diag.alt$.resid) # p > 0.05, residuals are normally distributed 

# Homoscedasticity 
car::ncvTest(alt.model) # p > 0.05, residuals are homoscedastic
lmtest::bptest(alt.model) # p > 0.05, residuals are homoscedastic

# General
gvlma(alt.model) # All assumptions are satisfied except for Link Function

# Residual plots
autoplot(alt.model) # Lines in plots 1 and 3 seem to have become more skewed
autoplot(model10)

# FINAL MODEL - Best model is model 10 because it satisfies all assumptions, has high R2 and all predictors are significant
final.wheat.model <- lm(log(Yield) ~  Avg_rate_n + Avg_gross_rate_n + Avg_gross_rate_p + I(Avg_gross_rate_k^2), train)
summary(final.wheat.model)  # R2 = 0.76, RSE = 0.24 (log) and 1.28 (original units), p < 0.0001 (***)

# Obtain unstandardized and standardized coefficients
# Unstandardized
final.wheat.model$coefficients
sort(as.vector(abs(final.wheat.model$coefficients)), decreasing = TRUE)

# Standardized
std.coef <- lm.beta(final.wheat.model) 

rank.coef <- data.frame(Predictor = names(std.coef$coefficients), 
                        Standardized_coefficient = unname(std.coef$standardized.coefficients))
rank.coef
arrange(rank.coef, -abs(Standardized_coefficient))

# Final goodness of fit graph
diag <- augment(final.wheat.model)
measured <- log(train$Yield)
predicted <- diag$.fitted
datos_gráfica <- as.data.frame(cbind(Measured = measured, Predicted = predicted))

ggplot(datos_gráfica, aes(Measured, Predicted)) + 
  geom_point(aes(col = "Predicted"), size = 2) + 
  geom_smooth(method = "lm", se = FALSE, aes(col = "Model line")) + 
  geom_line(data = datos_gráfica, aes(Measured, Measured, col = "Real line")) + 
  labs(x = "Measured values", y = "Predicted values") +
  coord_cartesian(xlim = c(min(measured), 1.01*max(measured)), ylim = c(min(measured), 1.1*max(predicted))) +
  scale_color_manual(name= "Legend",
                     breaks=c("Real line", "Model line", "Predicted"),
                     values=c("Real line" = "black", "Model line" = "blue" , "Predicted"= "red")) +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 0),
                                                  shape = c(NULL, NULL, 20),
                                                  size = c(1, 1, 2)))) +
  ggtitle(label = "Goodness of fit of wheat yield prediction model") +
  theme(legend.title= element_text(size= 15),
        legend.text= element_text(size= 13),
        legend.position = c(0.85, 0.2),
        legend.background = element_rect(fill="lightblue", 
                                         size=0.5, linetype="solid",
                                         colour ="black"), 
        legend.key = element_rect(fill = "lightblue"),
        axis.line.y = element_line(),
        axis.line.x = element_line(), 
        panel.border = element_rect(colour = "black", fill = NA), 
        plot.title = element_text(hjust = 0.5, size = 18), 
        axis.text.y = element_text(size = 13, angle = 90, hjust = 0.5),
        axis.text.x = element_text(size = 13),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15))




# POTATO YIELD PREDICTION ---- 
data <- read_excel("C:/Users/User/Documents/Data/Proyecto 1/proyecto1_R.xlsx", sheet = 4)
data <- as.data.frame(data)
head(data)

# Subsetting
train <- na.omit(data[,-c(1, 2)])
head(data)

# Exploratory analysis 
psych::describe(train)

corr_matrix <- round(cor(train), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 2.3)

# Fitting model 1 (full model)
model1 <- lm(Yield ~ ., train)
summary(model1) # R2 = 0.95, RSE = 1.9, p > 0.05 (ns)

# Stepwise regression model
step.model <- stepAIC(model1, direction = "both", 
                      trace = FALSE)
summary(step.model) # R2 = 0.95, RSE = 1.9, p > 0.05 (ns)

# Checking for multicollinearity
vif(step.model) # All variables have VIF > 10

# Fitting model with variables having r > 0.4 in correlation matrix 
model2 <- lm(Yield ~ Rate_pesticides + Avg_rate_n + Avg_tractor_density + 
               + Avg_rate_k + Min_temperature + Max_temperature + 
               Temperature, train)
summary(model2) # R2 = 0.66, RSE = 5.1, p < 0.05 (*) - Not all predictors are significant

# Checking for multicollinearity in model2 
vif(model2)

# Fitting model 3 (many variables and transformations were tested intuitively from agronomic criteria until a good model with all significant predictors was obtained)
model3 <- lm(I(Yield^{2}) ~ Avg_rate_k + Temperature + Rate_pesticides + I(Avg_irrigated_area^{2}) + I(Avg_gross_rate_n^{-1}), train)
summary(model3) # R2 = 0.86, RSE = 0.89 (squared) and 0.94 (original units), p < 0.0001 (***)

# Residual analysis
diag3 <- augment(model3)
diag3$.resid <- I(train$Yield^{2}) - diag3$.fitted

# Independence
durbinWatsonTest(model3) # p > 0.04, residuals are independent

# Normality
shapiro.test(diag3$.resid) # p > 0.05, residuals are normally distributed

# Homoscedasticity 
car::ncvTest(model3) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model3) # p > 0.05, residuals are homoscedastic

# General
gvlma(model3) # All assumptions acceptable except for link function

# Residual plots
autoplot(model3) # Line is considerably skewed in Residuals vs Fitted and many points fall away from the Normal Q-Q plot

# Fitting model4 including Avg_total_p
model4 <- lm(I(Yield^{2}) ~ sqrt(Avg_rate_k) + Temperature + Rate_pesticides + I(Avg_irrigated_area^{2}) + I(Avg_gross_rate_n^{-1}) + log(Avg_total_p), train)
summary(model4) # R2 = 0.84, RSE = 189.1 (squared), p < 0.0001 (***)

# Checking for multicollinearity in model 4
vif(model4)

# Residual analysis
diag4 <- augment(model4)
diag4$.resid <- I(train$Yield^{2}) - diag4$.fitted

# Independence
durbinWatsonTest(model4) # p > 0.05, residuals are independent

# Normality
shapiro.test(diag4$.resid) # p > 0.05, residuals are normally distributed

# Homoscedasticity
car::ncvTest(model4) # p > 0.05, residuals are homoscedastic
lmtest::bptest(model4) # p > 0.05, residuals are homoscedastic

# General
gvlma(model4) # All assumptions acceptable

# Residual plots
autoplot(model4) # Line in Residuals vs Fitted has reduced in skewness and the points have moved closer to the line in Normal Q-Q plot

# FINAL MODEL  
final.potato.model <- lm(I(Yield^{2}) ~ sqrt(Avg_rate_k) + Temperature + Rate_pesticides + I(Avg_irrigated_area^{2}) + I(Avg_gross_rate_n^{-1}) + log(Avg_total_p), train)
summary(final.potato.model) # R2 = 0.84, RSE = 189.1 (squared), p < 0.0001 (***)

# Obtain unstandardized and standardized coefficients
# Unstandardized
final.potato.model$coefficients
sort(as.vector(abs(final.potato.model$coefficients)), decreasing = TRUE)

# Standardized
std.coef <- lm.beta(final.potato.model) 

rank.coef <- data.frame(Predictor = names(std.coef$coefficients), 
                        Standardized_coefficient = unname(std.coef$standardized.coefficients))
rank.coef
arrange(rank.coef, -abs(Standardized_coefficient))

# Final goodness of fit graph
diag <- augment(final.potato.model)
measured <- I(train$Yield^{2})
predicted <- diag$.fitted
datos_gráfica <- as.data.frame(cbind(Measured = measured, Predicted = predicted))

ggplot(datos_gráfica, aes(Measured, Predicted)) + 
  geom_point(aes(col = "Predicted"), size = 2) + 
  geom_smooth(method = "lm", se = FALSE, aes(col = "Model line")) + 
  geom_line(data = datos_gráfica, aes(Measured, Measured, col = "Real line")) + 
  labs(x = "Measured values", y = "Predicted values") +
  coord_cartesian(xlim = c(min(predicted), 1.1*max(predicted)), ylim = c(min(predicted), 1.1*max(predicted))) +
  scale_color_manual(name= "Legend",
                     breaks=c("Real line", "Model line", "Predicted"),
                     values=c("Real line" = "black", "Model line" = "blue" , "Predicted"= "red")) +
  guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 0),
                                                  shape = c(NULL, NULL, 20),
                                                  size = c(1, 1, 2)))) +
  ggtitle(label = "Goodness of fit of potato yield prediction model") +
  theme(legend.title= element_text(size= 15),
        legend.text= element_text(size= 13),
        legend.position = c(0.85, 0.2),
        legend.background = element_rect(fill="lightblue", 
                                         size=0.5, linetype="solid",
                                         colour ="black"), 
        legend.key = element_rect(fill = "lightblue"),
        axis.line.y = element_line(),
        axis.line.x = element_line(), 
        panel.border = element_rect(colour = "black", fill = NA), 
        plot.title = element_text(hjust = 0.5, size = 18), 
        axis.text.y = element_text(size = 13, angle = 90, hjust = 0.5),
        axis.text.x = element_text(size = 13),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15))




